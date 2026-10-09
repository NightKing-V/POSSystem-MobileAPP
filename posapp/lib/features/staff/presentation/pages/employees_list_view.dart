import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../data/staff_repository.dart';
import './add_edit_employee_view.dart';

class EmployeesListView extends StatefulWidget {
  const EmployeesListView({super.key, this.orgId, this.isEmbedded = false});

  final String? orgId;
  final bool isEmbedded;

  @override
  State<EmployeesListView> createState() => _EmployeesListViewState();
}

class _EmployeesListViewState extends State<EmployeesListView> {
  final _staffRepo = StaffRepository();
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  List<StaffUserProps> _employees = [];
  bool _isLoading = false;

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final response = await _staffRepo.fetchStaffUsers(orgId: widget.orgId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _employees = response.data!;
      }
    });
  }

  List<StaffUserProps> get _processedEmployees {
    var list = _employees;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((e) =>
              e.name.toLowerCase().contains(q) ||
              e.email.toLowerCase().contains(q) ||
              (e.phone != null && e.phone!.contains(q)) ||
              (e.role != null && e.role!.toLowerCase().contains(q)) ||
              (e.locationName != null &&
                  e.locationName!.toLowerCase().contains(q)))
          .toList();
    }

    if (_sortColumnIndex != null) {
      list = List.of(list);
      list.sort((a, b) {
        int comp = 0;
        switch (_sortColumnIndex) {
          case 0:
            comp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case 1:
            comp = (a.role ?? '').toLowerCase().compareTo((b.role ?? '').toLowerCase());
            break;
          case 2:
            comp = (a.locationName ?? '').toLowerCase().compareTo((b.locationName ?? '').toLowerCase());
            break;
          case 3:
            comp = (a.isActive ? 1 : 0).compareTo(b.isActive ? 1 : 0);
            break;
        }
        return _sortAscending ? comp : -comp;
      });
    }

    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddEdit([StaffUserProps? employee]) async {
    final isEditing = employee != null;
    final res = await showResponsiveModal<bool>(
      context: context,
      title: isEditing ? context.tr('staff.edit_employee') : context.tr('staff.add_employee'),
      subtitle: isEditing
          ? employee.email
          : context.tr('staff.add_employee_subtitle'),
      leadingIcon: const Icon(Icons.badge_outlined,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 620,
      builder: (_) => AddEditEmployeeView(
        employee: employee,
        orgId: widget.orgId,
        isModal: true,
      ),
    );
    if (res == true) {
      _loadStaff();
    }
  }

  void _handleDelete(StaffUserProps employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('staff.delete_employee_confirm')),
        content: Text('${context.tr('common.confirm_delete_msg')} (${employee.name})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('common.cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('common.delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final effectiveOrgId = widget.orgId ?? TokenStorage.currentOrgId;
      final ApiResponse<Map<String, dynamic>> res;
      if (effectiveOrgId != null && effectiveOrgId.isNotEmpty) {
        res = await _staffRepo.unassignMember(
          orgId: effectiveOrgId,
          userId: employee.id,
        );
      } else {
        res = await _staffRepo.deleteUser(employee.id);
      }

      if (!mounted) return;

      if (res.isSuccess) {
        setState(() {
          _employees.removeWhere((e) => e.id == employee.id);
        });
        ApiHelper.showSuccessSnackBar(
          context,
          '${employee.name} ${context.tr('common.deleted_success').toLowerCase()}.',
        );
      } else {
        ApiHelper.showErrorSnackBar(
          context,
          res.errorMessage ?? context.tr('common.error'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = _processedEmployees;

    final body = Column(
      children: [
        ManagementHeaderBar(
          title: context.tr('staff.title'),
          subtitle: context.tr('staff.subtitle'),
          itemCountText: context.tr('staff.count_members', args: {'count': '${employees.length}'}),
          searchCtrl: _searchCtrl,
          searchHint: context.tr('common.search'),
          onSearchChanged: (v) => setState(() => _search = v),
          actionLabel: context.tr('staff.add_employee'),
          actionIcon: Icons.person_add_outlined,
          onActionTap: () => _openAddEdit(),
        ),
        Expanded(
          child: ManagementGridTable<StaffUserProps>(
            items: employees,
            isLoading: _isLoading,
            emptyTitle: context.tr('staff.no_staff_found'),
            emptySubtitle: context.tr('staff.adjust_search_hint'),
            emptyIcon: Icons.person_search_outlined,
            enablePagination: true,
            rowsPerPage: 10,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: (colIdx, asc) {
              setState(() {
                _sortColumnIndex = colIdx;
                _sortAscending = asc;
              });
            },
            onEdit: (e) => _openAddEdit(e),
            onDelete: (e) => _handleDelete(e),
            columns: [
              ManagementTableColumn<StaffUserProps>(
                label: context.tr('staff.staff_member'),
                flex: 3,
                isSortable: true,
                cellBuilder: (emp, _) {
                  final initials = emp.name
                      .split(' ')
                      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                      .take(2)
                      .join();
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor:
                            AppColors.inkTeal.withValues(alpha: 0.1),
                        child: Text(
                          initials.isNotEmpty ? initials : 'S',
                          style: const TextStyle(
                            color: AppColors.inkTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              emp.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              emp.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.slate,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              ManagementTableColumn<StaffUserProps>(
                label: context.tr('staff.role_designation'),
                flex: 2,
                isSortable: true,
                cellBuilder: (emp, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.inkTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      emp.role ?? 'Employee',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkTeal,
                      ),
                    ),
                  ),
                ),
              ),
              ManagementTableColumn<StaffUserProps>(
                label: context.tr('staff.assigned_branch'),
                flex: 2,
                isSortable: true,
                cellBuilder: (emp, _) => Text(
                  emp.locationName ?? context.tr('staff.all_locations'),
                  style: const TextStyle(fontSize: 13, color: AppColors.slate),
                ),
              ),
              ManagementTableColumn<StaffUserProps>(
                label: context.tr('common.status'),
                width: 110,
                isSortable: true,
                cellBuilder: (emp, _) => _StatusDot(active: emp.isActive),
              ),
            ],
            cardBuilder: (context, emp, _) => _EmployeeTile(
              employee: emp,
              onTap: () => _openAddEdit(emp),
            ),
          ),
        ),
      ],
    );

    final fab = ManagementHeaderBar.buildFab(
      context,
      label: context.tr('staff.add_employee'),
      icon: Icons.person_add_outlined,
      onTap: () => _openAddEdit(),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: body,
        floatingActionButton: fab,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.tr('staff.title'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text(context.tr('staff.count_members', args: {'count': '${employees.length}'}),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: SafeArea(child: body),
      floatingActionButton: fab,
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.onTap});

  final StaffUserProps employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = employee.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.hairline.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.inkTeal.withValues(alpha: 0.1),
                child: Text(
                  initials.isNotEmpty ? initials : 'S',
                  style: const TextStyle(
                      color: AppColors.inkTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: AppColors.ink),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _StatusDot(active: employee.isActive),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(employee.role ?? 'Employee',
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.inkTeal,
                                fontWeight: FontWeight.w600)),
                        if (employee.locationName != null) ...[
                          const Text(' · ',
                              style: TextStyle(
                                  fontSize: 11.5, color: AppColors.slate)),
                          Expanded(
                            child: Text(
                              employee.locationName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.slate),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.slate, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF0F9D58).withValues(alpha: 0.1)
            : AppColors.slate.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFF0F9D58) : AppColors.slate,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            active ? context.tr('common.active') : context.tr('common.inactive'),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF0F9D58) : AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }
}
