import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../data/staff_repository.dart';
import './add_edit_permission_set_view.dart';

class PermissionSetsListView extends StatefulWidget {
  const PermissionSetsListView({
    super.key,
    this.orgId,
    this.isEmbedded = false,
    this.onBack,
  });

  final String? orgId;
  final bool isEmbedded;
  final VoidCallback? onBack;

  @override
  State<PermissionSetsListView> createState() => _PermissionSetsListViewState();
}

class _PermissionSetsListViewState extends State<PermissionSetsListView> {
  final _staffRepo = StaffRepository();
  List<OrgRoleProps> _roles = [];
  bool _isLoading = false;

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  String? get _effectiveOrgId => widget.orgId ?? TokenStorage.currentOrgId;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    final res = await _staffRepo.fetchOrgRoles(orgId: _effectiveOrgId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res.isSuccess && res.data != null) {
        _roles = res.data!;
      }
    });
  }

  List<OrgRoleProps> get _processedRoles {
    var list = _roles;
    if (_sortColumnIndex != null) {
      list = List.of(list);
      list.sort((a, b) {
        int comp = 0;
        switch (_sortColumnIndex) {
          case 0:
            comp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case 1:
            comp = (a.description ?? '')
                .toLowerCase()
                .compareTo((b.description ?? '').toLowerCase());
            break;
          case 2:
            comp = a.permissions.length.compareTo(b.permissions.length);
            break;
          case 3:
            comp = a.userRolesCount.compareTo(b.userRolesCount);
            break;
        }
        return _sortAscending ? comp : -comp;
      });
    }
    return list;
  }

  void _openAddEdit([OrgRoleProps? role]) async {
    final isEditing = role != null;
    final res = await showResponsiveModal<bool>(
      context: context,
      title: isEditing ? context.tr('staff.edit_role') : context.tr('staff.add_role'),
      subtitle:
          isEditing ? role.name : context.tr('staff.no_roles_hint'),
      leadingIcon: const Icon(Icons.security_outlined,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 640,
      builder: (_) => AddEditPermissionSetView(
        role: role,
        orgId: _effectiveOrgId,
        isModal: true,
      ),
    );
    if (res == true) _loadRoles();
  }

  void _handleDelete(OrgRoleProps role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('staff.delete_role_confirm')),
        content: Text(
          context.tr('common.confirm_delete_msg'),
        ),
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
      final res = await _staffRepo.deleteOrgRole(role.id);
      if (!mounted) return;

      if (res.isSuccess) {
        setState(() {
          _roles.removeWhere((r) => r.id == role.id);
        });
        ApiHelper.showSuccessSnackBar(context, context.tr('common.deleted_success'));
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
    final roles = _processedRoles;

    final body = Column(
      children: [
        ManagementHeaderBar(
          title: context.tr('staff.roles'),
          subtitle: context.tr('settings.permission_sets'),
          itemCountText:
              '${roles.length} ${roles.length == 1 ? 'role' : 'roles'}',
          leading: (widget.onBack != null || Navigator.of(context).canPop())
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                  tooltip: context.tr('common.back'),
                  onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                )
              : null,
          hideMobileTitle: false,
          actionLabel: context.tr('staff.add_role'),
          actionIcon: Icons.add,
          onActionTap: () => _openAddEdit(),
        ),
        Expanded(
          child: ManagementGridTable<OrgRoleProps>(
            items: roles,
            isLoading: _isLoading,
            emptyTitle: context.tr('staff.no_roles'),
            emptySubtitle: context.tr('staff.no_roles_hint'),
            emptyIcon: Icons.admin_panel_settings_outlined,
            enablePagination: true,
            rowsPerPage: 10,
            gridMainAxisExtent: 140,
            gridMaxCrossAxisExtent: 460,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: (colIdx, asc) {
              setState(() {
                _sortColumnIndex = colIdx;
                _sortAscending = asc;
              });
            },
            onEdit: (r) => _openAddEdit(r),
            onDelete: (r) => _handleDelete(r),
            columns: [
              ManagementTableColumn<OrgRoleProps>(
                label: context.tr('staff.role_name'),
                flex: 2,
                isSortable: true,
                cellBuilder: (role, _) => Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.inkTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_outlined,
                        color: AppColors.inkTeal,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            role.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          if (role.isSystem || role.isLocationScoped)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Wrap(
                                spacing: 4,
                                children: [
                                  if (role.isSystem)
                                    _BadgeChip(
                                      label: context.tr('staff.system_role'),
                                      color: AppColors.inkTeal,
                                    ),
                                  if (role.isLocationScoped)
                                    _BadgeChip(
                                      label: context.tr('staff.location_scoped'),
                                      color: AppColors.marigold,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ManagementTableColumn<OrgRoleProps>(
                label: context.tr('common.description'),
                flex: 3,
                isSortable: true,
                cellBuilder: (role, _) => Text(
                  role.description ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.slate,
                  ),
                ),
              ),
              ManagementTableColumn<OrgRoleProps>(
                label: context.tr('staff.employees'),
                width: 130,
                isSortable: true,
                cellBuilder: (role, _) => Text(
                  '${role.userRolesCount}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              ManagementTableColumn<OrgRoleProps>(
                label: context.tr('staff.access_permissions'),
                flex: 3,
                isSortable: true,
                cellBuilder: (role, _) => Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: role.permissions
                      .take(3)
                      .map((perm) => _PermChip(label: perm))
                      .toList(),
                ),
              ),
            ],
            cardBuilder: (context, role, _) => _PermissionSetCard(
              role: role,
              onTap: () => _openAddEdit(role),
            ),
          ),
        ),
      ],
    );

    final fab = ManagementHeaderBar.buildFab(
      context,
      label: context.tr('staff.add_role'),
      onTap: () => _openAddEdit(),
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(top: false, child: body),
        floatingActionButton: fab,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.tr('staff.roles'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text('${roles.length} ${context.tr('staff.roles')}',
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

class _PermissionSetCard extends StatelessWidget {
  const _PermissionSetCard({required this.role, required this.onTap});

  final OrgRoleProps role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.hairline.withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.inkTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.admin_panel_settings_outlined,
                        color: AppColors.inkTeal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                role.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14.5),
                              ),
                            ),
                            if (role.isLocationScoped)
                              _BadgeChip(
                                label: context.tr('staff.location_scoped_short'),
                                color: AppColors.marigold,
                              ),
                          ],
                        ),
                        Text(
                          role.description ?? context.tr('staff.custom_role'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.slate),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.slate, size: 18),
                ],
              ),
              if (role.permissions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: role.permissions
                      .take(4)
                      .map((perm) => _PermChip(label: perm))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _PermChip extends StatelessWidget {
  const _PermChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: AppColors.inkTeal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: AppColors.inkTeal.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.inkTeal),
      ),
    );
  }
}
