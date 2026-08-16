import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/mock_data.dart';

class AddEditPermissionSetView extends StatefulWidget {
  const AddEditPermissionSetView({super.key, this.permissionSet});

  final MockPermissionSet? permissionSet;

  @override
  State<AddEditPermissionSetView> createState() =>
      _AddEditPermissionSetViewState();
}

class _AddEditPermissionSetViewState extends State<AddEditPermissionSetView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late Map<String, bool> _permissions;

  bool get _isEditing => widget.permissionSet != null;

  bool get _allEnabled =>
      _permissions.values.every((v) => v);

  @override
  void initState() {
    super.initState();
    final ps = widget.permissionSet;
    _nameCtrl = TextEditingController(text: ps?.name ?? '');
    _permissions = ps != null
        ? Map.of(ps.permissions)
        : {for (final c in kPermissionCategories) c: false};
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggleAll(bool value) {
    setState(() {
      for (final key in _permissions.keys) {
        _permissions[key] = value;
      }
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Permission set updated.'
              : 'Permission set created.'),
          backgroundColor: AppColors.inkTeal,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role name card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.hairline.withValues(alpha: 0.6),
                            width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Role name',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontSize: 16)),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nameCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                                hintText: 'e.g. Cashier, Manager'),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Please enter a role name'
                                    : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Permissions card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.hairline.withValues(alpha: 0.6),
                            width: 1.5),
                      ),
                      child: Column(
                        children: [
                          // Full-access master switch
                          SwitchListTile(
                            value: _allEnabled,
                            onChanged: _toggleAll,
                            activeThumbColor: AppColors.inkTeal,
                            title: const Text(
                              'Full Access',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            subtitle: const Text(
                              'Enable all permissions at once',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.slate),
                            ),
                            secondary: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.inkTeal.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: AppColors.inkTeal,
                                  size: 20),
                            ),
                          ),
                          const Divider(
                              color: AppColors.hairline, height: 1, indent: 64),

                          // Per-permission toggles
                          for (int i = 0;
                              i < kPermissionCategories.length;
                              i++) ...[
                            _PermissionTile(
                              category: kPermissionCategories[i],
                              value: _permissions[kPermissionCategories[i]] ??
                                  false,
                              onChanged: (v) => setState(() =>
                                  _permissions[kPermissionCategories[i]] = v),
                            ),
                            if (i != kPermissionCategories.length - 1)
                              const Divider(
                                  color: AppColors.hairline,
                                  height: 1,
                                  indent: 64),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.inkTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Create Role',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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

