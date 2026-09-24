import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/staff_repository.dart';

const List<String> kDefaultPermissionCategories = [
  'POS Access',
  'Discounts',
  'Refunds',
  'Reports',
  'Inventory',
  'Settings',
];

class AddEditPermissionSetView extends StatefulWidget {
  const AddEditPermissionSetView({super.key, this.role, this.isModal = true});

  final RoleProps? role;
  final bool isModal;

  @override
  State<AddEditPermissionSetView> createState() =>
      _AddEditPermissionSetViewState();
}

class _AddEditPermissionSetViewState extends State<AddEditPermissionSetView> {
  final _staffRepo = StaffRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late Map<String, bool> _permissions;
  bool _isSaving = false;

  bool get _isEditing => widget.role != null;

  bool get _allEnabled => _permissions.values.every((v) => v);

  @override
  void initState() {
    super.initState();
    final r = widget.role;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _permissions = {
      for (final c in kDefaultPermissionCategories)
        c: r != null ? r.permissions.contains(c) : false
    };
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _toggleAll(bool value) {
    setState(() {
      for (final key in _permissions.keys) {
        _permissions[key] = value;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final selectedPerms = _permissions.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final dto = CreateRoleDto(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      permissions: selectedPerms,
    );

    final res = await _staffRepo.createRole(dto);
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (res.isSuccess) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Role updated.' : 'Role created.'),
          backgroundColor: AppColors.inkTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.errorMessage ?? 'Failed to save role.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formBody = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Role Name *',
                  hintText: 'e.g. Cashier, Store Manager, Supervisor'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? 'Please enter a role name'
                      : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g. Front desk billing & order dispatch'),
            ),
            const SizedBox(height: 24),

            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 20),

            Text(
              'Access Permissions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 12),

            // Master switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _allEnabled,
              onChanged: _toggleAll,
              activeThumbColor: AppColors.inkTeal,
              title: const Text(
                'Full Access',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: const Text(
                'Grant all permissions across the platform',
                style: TextStyle(fontSize: 12, color: AppColors.slate),
              ),
              secondary: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.inkTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_user_outlined,
                    color: AppColors.inkTeal, size: 20),
              ),
            ),
            const Divider(color: AppColors.hairline, height: 1),

            // Permission toggles
            for (int i = 0; i < kDefaultPermissionCategories.length; i++) ...[
              _PermissionTile(
                category: kDefaultPermissionCategories[i],
                value: _permissions[kDefaultPermissionCategories[i]] ?? false,
                onChanged: (v) => setState(() =>
                    _permissions[kDefaultPermissionCategories[i]] = v),
              ),
              if (i != kDefaultPermissionCategories.length - 1)
                const Divider(color: AppColors.hairline, height: 1),
            ],

            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate,
                      side: const BorderSide(color: AppColors.hairline, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 52),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.inkTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 52),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isEditing ? 'Save Changes' : 'Create Role',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (widget.isModal) {
      return formBody;
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          _isEditing ? 'Edit Role' : 'New Role',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: formBody),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.category,
    required this.value,
    required this.onChanged,
  });

  final String category;
  final bool value;
  final ValueChanged<bool> onChanged;

  static const _icons = <String, IconData>{
    'POS Access': Icons.point_of_sale_outlined,
    'Discounts': Icons.local_offer_outlined,
    'Refunds': Icons.replay_outlined,
    'Reports': Icons.bar_chart_outlined,
    'Inventory': Icons.inventory_2_outlined,
    'Settings': Icons.settings_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.inkTeal,
      title: Text(category,
          style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      secondary: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.inkTeal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_icons[category] ?? Icons.lock_outline,
            color: AppColors.inkTeal, size: 20),
      ),
    );
  }
}
