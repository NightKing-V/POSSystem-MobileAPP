import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../data/staff_repository.dart';
import './add_edit_permission_set_view.dart';

class PermissionSetsListView extends StatefulWidget {
  const PermissionSetsListView({super.key});

  @override
  State<PermissionSetsListView> createState() => _PermissionSetsListViewState();
}

class _PermissionSetsListViewState extends State<PermissionSetsListView> {
  final _staffRepo = StaffRepository();
  List<RoleProps> _roles = [];
  bool _isLoading = false;

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    final res = await _staffRepo.fetchRoles();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res.isSuccess && res.data != null) {
        _roles = res.data!;
      }
    });
  }

  List<RoleProps> get _processedRoles {
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
        }
        return _sortAscending ? comp : -comp;
      });
    }
    return list;
  }

  void _openAddEdit([RoleProps? role]) async {
    final isEditing = role != null;
    final res = await showResponsiveModal<bool>(
      context: context,
      title: isEditing ? 'Edit Role' : 'New Role',
      subtitle:
          isEditing ? role.name : 'Configure access control and permissions',
      leadingIcon: const Icon(Icons.security_outlined,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 620,
      builder: (_) => AddEditPermissionSetView(
        role: role,
        isModal: true,
      ),
    );
    if (res == true) _loadRoles();
  }

  void _handleDelete(RoleProps role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to remove role "${role.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _roles.removeWhere((r) => r.id == role.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role "${role.name}" deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
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
          title: 'Permission Sets',
          subtitle: 'Staff Roles & Granular Permission Scopes',
          itemCountText:
              '${roles.length} ${roles.length == 1 ? 'role' : 'roles'}',
          actionLabel: 'Add Role',
          actionIcon: Icons.add,
          onActionTap: () => _openAddEdit(),
        ),
        Expanded(
          child: ManagementGridTable<RoleProps>(
            items: roles,
            isLoading: _isLoading,
            emptyTitle: 'No roles defined',
            emptySubtitle:
                'Create staff roles to configure granular access permissions for your employees.',
            emptyIcon: Icons.admin_panel_settings_outlined,
            enablePagination: true,
            rowsPerPage: 10,
            gridMainAxisExtent: 130,
            gridMaxCrossAxisExtent: 440,
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
              ManagementTableColumn<RoleProps>(
                label: 'Role Name',
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
                    Text(
                      role.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              ManagementTableColumn<RoleProps>(
                label: 'Description',
                flex: 3,
                isSortable: true,
                cellBuilder: (role, _) => Text(
                  role.description ?? 'Custom access role',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.slate,
                  ),
                ),
              ),
              ManagementTableColumn<RoleProps>(
                label: 'Configured Permissions',
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
      label: 'Add Role',
      onTap: () => _openAddEdit(),
    );

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
            Text('Permission Sets',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text('${roles.length} roles configured',
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

  final RoleProps role;
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
                        Text(
                          role.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14.5),
                        ),
                        Text(
                          role.description ?? 'Custom access role',
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
