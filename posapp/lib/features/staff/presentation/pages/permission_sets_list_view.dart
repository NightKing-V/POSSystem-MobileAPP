import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/domain/mock_data.dart';
import './add_edit_permission_set_view.dart';

class PermissionSetsListView extends StatelessWidget {
  const PermissionSetsListView({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text('Define staff roles and access',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              itemCount: mockPermissionSets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _PermissionSetCard(
                ps: mockPermissionSets[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(fullscreenDialog: true, 
                    builder: (_) => AddEditPermissionSetView(
                        permissionSet: mockPermissionSets[i]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(fullscreenDialog: true, 
              builder: (_) => const AddEditPermissionSetView()),
        ),
        backgroundColor: AppColors.inkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Role',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _PermissionSetCard extends StatelessWidget {
  const _PermissionSetCard({required this.ps, required this.onTap});

  final MockPermissionSet ps;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enabled =
        ps.permissions.entries.where((e) => e.value).map((e) => e.key).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.inkTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.admin_panel_settings_outlined,
                      color: AppColors.inkTeal, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ps.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${ps.employeeCount} employees',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.slate, size: 18),
              ],
            ),
            if (enabled.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: enabled
                    .map((perm) => _PermChip(label: perm))
                    .toList(),
              ),
            ],
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.inkTeal.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: AppColors.inkTeal.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.inkTeal),
      ),
    );
  }
}
