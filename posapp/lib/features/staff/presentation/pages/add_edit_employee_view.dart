import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/staff_repository.dart';

class AddEditEmployeeView extends StatefulWidget {
  const AddEditEmployeeView({
    super.key,
    this.employee,
    this.orgId,
    this.isModal = true,
  });

  final StaffUserProps? employee;
  final String? orgId;
  final bool isModal;

  @override
  State<AddEditEmployeeView> createState() => _AddEditEmployeeViewState();
}

class _AddEditEmployeeViewState extends State<AddEditEmployeeView> {
  final _staffRepo = StaffRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passwordCtrl;

  String? _selectedRoleId;
  List<OrgRoleProps> _availableRoles = [];
  bool _isLoadingRoles = false;
  bool _isLoading = false;

  bool get _isEditing => widget.employee != null;

  String? get _effectiveOrgId => widget.orgId ?? TokenStorage.currentOrgId;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _phoneCtrl = TextEditingController(text: e?.phone ?? '');
    _passwordCtrl = TextEditingController();
    _selectedRoleId = e?.roleId;

    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoadingRoles = true);
    final res = await _staffRepo.fetchOrgRoles(orgId: _effectiveOrgId);
    if (!mounted) return;

    setState(() {
      _isLoadingRoles = false;
      if (res.isSuccess && res.data != null) {
        _availableRoles = res.data!;
        if (_selectedRoleId == null && _availableRoles.isNotEmpty) {
          final matched = _availableRoles.where(
            (r) => r.name.toLowerCase() == (widget.employee?.role ?? '').toLowerCase(),
          );
          if (matched.isNotEmpty) {
            _selectedRoleId = matched.first.id;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dto = CreateStaffUserDto(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      password:
          _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : 'Password@123',
      roleId: _selectedRoleId,
    );

    final res = await _staffRepo.createStaffUser(dto);

    if (!mounted) return;

    if (res.isSuccess) {
      // If editing and role was selected, assign the role explicitly
      if (_isEditing &&
          _selectedRoleId != null &&
          _effectiveOrgId != null &&
          widget.employee != null) {
        await _staffRepo.assignOrgRole(
          orgId: _effectiveOrgId!,
          userId: widget.employee!.id,
          roleId: _selectedRoleId!,
        );
        if (!mounted) return;
      }

      setState(() => _isLoading = false);
      ApiHelper.showSuccessSnackBar(
        context,
        _isEditing ? context.tr('common.updated_success') : context.tr('common.created_success'),
      );
      Navigator.of(context).pop(true);
    } else {
      setState(() => _isLoading = false);
      ApiHelper.showErrorSnackBar(
        context,
        res.errorMessage ?? context.tr('common.error'),
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
              context.tr('staff.employees'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 14),
            _FieldLabel(context.tr('staff.employee_name')),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: context.tr('staff.employee_name_hint')),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? context.tr('customers.name_required') : null,
            ),
            const SizedBox(height: 16),
            _FieldLabel('${context.tr('auth.email')} *'),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: context.tr('auth.email_hint')),
              validator: (v) => (v == null || !v.contains('@'))
                  ? context.tr('auth.invalid_email')
                  : null,
            ),
            const SizedBox(height: 16),
            _FieldLabel(context.tr('auth.phone')),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(hintText: context.tr('auth.phone_hint')),
            ),
            const SizedBox(height: 16),
            _FieldLabel(context.tr('staff.role')),
            if (_isLoadingRoles)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedRoleId,
                decoration: InputDecoration(
                  hintText: context.tr('staff.select_role'),
                  prefixIcon: const Icon(Icons.admin_panel_settings_outlined,
                      color: AppColors.slate, size: 20),
                ),
                items: _availableRoles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role.id,
                    child: Text(
                      role.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedRoleId = val);
                },
              ),
            if (!_isEditing) ...[
              const SizedBox(height: 16),
              _FieldLabel('${context.tr('auth.password')} *'),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(hintText: context.tr('auth.password_hint')),
                validator: (v) => (v == null || v.length < 8)
                    ? context.tr('auth.password_min_length')
                    : null,
              ),
            ],
          ],
        ),
      ),
    );

    final actionButtons = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate,
                side: const BorderSide(
                    color: AppColors.hairline, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(0, 48),
              ),
              child: Text(context.tr('common.cancel')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(0, 48),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isEditing
                          ? context.tr('common.save')
                          : context.tr('staff.add_employee'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: formBody),
        actionButtons,
      ],
    );

    if (widget.isModal) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          _isEditing ? context.tr('staff.edit_employee') : context.tr('staff.add_employee'),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: content),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
      ),
    );
  }
}
