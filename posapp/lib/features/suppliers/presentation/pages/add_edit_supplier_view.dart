import 'package:flutter/material.dart';
import 'package:posapp/features/suppliers/domain/models/supplier_mock_data.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/suppliers_repository.dart';

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

    final res = await _suppliersRepo.createSupplier(dto);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        _isEditing ? 'Supplier updated.' : 'Supplier added.',
      );
      Navigator.of(context).pop(true);
    } else {
      ApiHelper.showErrorSnackBar(
        context,
        res.errorMessage ?? 'Failed to save supplier.',
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
              'Supplier Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 14),
            _FieldLabel('${context.tr('suppliers.supplier_name')} *'),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Lanka Fresh Distributors',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Supplier name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            _FieldLabel(context.tr('suppliers.contact_person')),
            TextFormField(
              controller: _contactCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Bandara Silva',
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Phone Number'),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+94 11 234 5678',
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Email Address'),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'orders@supplier.lk',
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.hairline, height: 1),
            const SizedBox(height: 20),
            Text(
              'Address & Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 14),
            _FieldLabel('Physical Address'),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. 100 Main Street, Pettah',
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel('Notes'),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Payment terms, delivery schedules…',
              ),
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
                        color: AppColors.hairline,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                            _isEditing
                                ? 'Update Supplier'
                                : context.tr('common.save'),
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
          _isEditing ? 'Edit Supplier' : context.tr('suppliers.add_supplier'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: formBody),
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
