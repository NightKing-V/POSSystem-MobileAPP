import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/staff_repository.dart';

class AddEditEmployeeView extends StatefulWidget {
  const AddEditEmployeeView({super.key, this.employee, this.orgId});

  final StaffUserProps? employee;
  final String? orgId;

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
  bool _isLoading = false;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _phoneCtrl = TextEditingController(text: e?.phone ?? '');
    _passwordCtrl = TextEditingController();
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
      password: _passwordCtrl.text.isNotEmpty ? _passwordCtrl.text : 'Password@123',
    );

    final res = await _staffRepo.createStaffUser(dto);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        _isEditing ? 'Employee updated.' : 'Employee added successfully.',
      );
      Navigator.of(context).pop(true);
    } else {
      ApiHelper.showErrorSnackBar(
        context,
        res.errorMessage ?? 'Failed to save employee.',
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
          _isEditing ? 'Edit Employee' : context.tr('staff.add_employee'),
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
                    _FormCard(
                      title: 'Employee Details',
                      children: [
                        _FieldLabel('${context.tr('customers.name')} *'),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration:
                              const InputDecoration(hintText: 'e.g. Ashan Perera'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('${context.tr('auth.email')} *'),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              const InputDecoration(hintText: 'e.g. ashan@store.lk'),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? 'Valid email is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(context.tr('customers.phone')),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration:
                              const InputDecoration(hintText: '+94 77 123 4567'),
                        ),
                        if (!_isEditing) ...[
                          const SizedBox(height: 16),
                          _FieldLabel('${context.tr('auth.password')} *'),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: true,
                            decoration:
                                const InputDecoration(hintText: 'Set temporary password'),
                            validator: (v) =>
                                (v == null || v.length < 6) ? 'At least 6 characters required' : null,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
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
                              minimumSize: const Size(0, 52),
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
                              minimumSize: const Size(0, 52),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    _isEditing ? 'Update Employee' : context.tr('common.save'),
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

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 15)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
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
