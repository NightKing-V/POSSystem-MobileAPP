import 'package:flutter/material.dart';
import 'package:posapp/features/suppliers/domain/models/supplier_mock_data.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/form_field_label.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../data/suppliers_repository.dart';
import '../validators/supplier_validators.dart';

class AddEditSupplierView extends StatefulWidget {
  const AddEditSupplierView({
    super.key,
    this.supplier,
    this.vendor,
    this.orgId,
    this.isModal = true,
  });

  final SupplierProps? supplier;
  final Vendor? vendor;
  final String? orgId;
  final bool isModal;

  @override
  State<AddEditSupplierView> createState() => _AddEditSupplierViewState();
}

class _AddEditSupplierViewState extends State<AddEditSupplierView> {
  final _suppliersRepo = SuppliersRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;
  bool _isLoading = false;

  bool get _isEditing => widget.supplier != null || widget.vendor != null;

  @override
  void initState() {
    super.initState();
    final name = widget.supplier?.name ?? widget.vendor?.name ?? '';
    final contact = widget.supplier?.contactPerson ?? widget.vendor?.contactPerson ?? '';
    final phone = widget.supplier?.phone ?? widget.vendor?.phone ?? '';
    final email = widget.supplier?.email ?? widget.vendor?.email ?? '';
    final address = widget.supplier?.address ?? widget.vendor?.address ?? '';
    final notes = widget.supplier?.description ?? widget.vendor?.notes ?? '';

    _nameCtrl = TextEditingController(text: name);
    _contactCtrl = TextEditingController(text: contact);
    _phoneCtrl = TextEditingController(text: phone);
    _emailCtrl = TextEditingController(text: email);
    _addressCtrl = TextEditingController(text: address);
    _notesCtrl = TextEditingController(text: notes);
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _contactCtrl,
      _phoneCtrl,
      _emailCtrl,
      _addressCtrl,
      _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dto = CreateSupplierDto(
      orgId: widget.orgId ?? '00000000-0000-0000-0000-000000000000',
      name: _nameCtrl.text.trim(),
      contactPerson: _contactCtrl.text.trim().isNotEmpty
          ? _contactCtrl.text.trim()
          : null,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      address: _addressCtrl.text.trim().isNotEmpty
          ? _addressCtrl.text.trim()
          : null,
      description: _notesCtrl.text.trim().isNotEmpty
          ? _notesCtrl.text.trim()
          : null,
    );

    final id = widget.supplier?.id ?? widget.vendor?.id;
    final res = (_isEditing && id != null && id.isNotEmpty)
        ? await _suppliersRepo.updateSupplier(id, dto.toJson())
        : await _suppliersRepo.createSupplier(dto);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        _isEditing ? context.tr('common.updated_success') : context.tr('common.created_success'),
      );
      Navigator.of(context).pop(true);
    } else {
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
              context.tr('suppliers.title'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              label: context.tr('suppliers.supplier_name'),
              isRequired: true,
              controller: _nameCtrl,
              hintText: context.tr('suppliers.supplier_name_hint'),
              validator: SupplierValidators.supplierName.validate,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: context.tr('suppliers.contact_person'),
              isRequired: false,
              controller: _contactCtrl,
              hintText: context.tr('suppliers.contact_person_hint'),
              validator: SupplierValidators.contactPerson.validate,
            ),
            const SizedBox(height: 16),
            FormFieldLabel(label: context.tr('common.phone')),
            PhoneInputField(
              controller: _phoneCtrl,
              isRequired: false,
              hintText: context.tr('customers.phone_hint'),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: context.tr('common.email'),
              isRequired: false,
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              hintText: context.tr('customers.email_hint'),
              validator: SupplierValidators.email.validate,
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 20),
            Text(
              context.tr('customers.contact_and_address'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              label: context.tr('common.address'),
              isRequired: false,
              controller: _addressCtrl,
              hintText: context.tr('customers.address_hint'),
              validator: SupplierValidators.address.validate,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: context.tr('common.description'),
              isRequired: false,
              controller: _notesCtrl,
              maxLines: 3,
              hintText: context.tr('suppliers.no_suppliers_hint'),
              validator: SupplierValidators.notes.validate,
            ),
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
                  color: AppColors.hairline,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                  borderRadius: BorderRadius.circular(8),
                ),
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
                          : context.tr('suppliers.add_supplier'),
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
          _isEditing ? context.tr('suppliers.edit_supplier') : context.tr('suppliers.add_supplier'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: content),
    );
  }
}
