import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/suppliers_repository.dart';

class AddEditSupplierView extends StatefulWidget {
  const AddEditSupplierView({super.key, this.supplier, this.orgId});

  final SupplierProps? supplier;
  final String? orgId;

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

  bool get _isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    final v = widget.supplier;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _contactCtrl = TextEditingController(text: v?.contactPerson ?? '');
    _phoneCtrl = TextEditingController(text: v?.phone ?? '');
    _emailCtrl = TextEditingController(text: v?.email ?? '');
    _addressCtrl = TextEditingController(text: v?.address ?? '');
    _notesCtrl = TextEditingController(text: v?.description ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _contactCtrl,
      _phoneCtrl,
      _emailCtrl,
      _addressCtrl,
      _notesCtrl
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
      contactPerson: _contactCtrl.text.trim().isNotEmpty ? _contactCtrl.text.trim() : null,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
      description: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
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
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          _isEditing ? 'Edit Supplier' : context.tr('suppliers.add_supplier'),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormCard(
                      title: 'Supplier Details',
                      children: [
                        _FieldLabel('${context.tr('suppliers.supplier_name')} *'),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              hintText: 'e.g. Lanka Fresh Distributors'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Supplier name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(context.tr('suppliers.contact_person')),
                        TextFormField(
                          controller: _contactCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              hintText: 'e.g. Bandara Silva'),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Phone Number'),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration:
                              const InputDecoration(hintText: '+94 11 234 5678'),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Email Address'),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              hintText: 'orders@supplier.lk'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormCard(
                      title: 'Address & Notes',
                      children: [
                        _FieldLabel('Physical Address'),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(
                              hintText: 'e.g. 100 Main Street, Pettah'),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Notes'),
                        TextFormField(
                          controller: _notesCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              hintText: 'Payment terms, delivery schedules…'),
                        ),
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
                                    _isEditing ? 'Update Supplier' : context.tr('common.save'),
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
