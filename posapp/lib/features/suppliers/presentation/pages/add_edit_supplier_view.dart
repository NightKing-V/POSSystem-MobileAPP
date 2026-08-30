import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/supplier_mock_data.dart';

class AddEditSupplierView extends StatefulWidget {
  const AddEditSupplierView({super.key, this.vendor});

  final Vendor? vendor;

  @override
  State<AddEditSupplierView> createState() => _AddEditSupplierViewState();
}

class _AddEditSupplierViewState extends State<AddEditSupplierView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  bool get _isEditing => widget.vendor != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vendor;
    _nameCtrl    = TextEditingController(text: v?.name ?? '');
    _contactCtrl = TextEditingController(text: v?.contactPerson ?? '');
    _phoneCtrl   = TextEditingController(text: v?.phone ?? '');
    _emailCtrl   = TextEditingController(text: v?.email ?? '');
    _addressCtrl = TextEditingController(text: v?.address ?? '');
    _notesCtrl   = TextEditingController(text: v?.notes ?? '');
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _contactCtrl, _phoneCtrl,
                     _emailCtrl, _addressCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Supplier updated.'
              : 'Supplier added.'),
          backgroundColor: AppColors.inkTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
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
          _isEditing ? 'Edit Supplier' : 'Add Supplier',
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
                      title: 'Supplier details',
                      children: [
                        _FieldLabel('Business Name *'),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              hintText: 'e.g. Lanka Fresh Distributors'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Enter supplier name'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Contact Person *'),
                        TextFormField(
                          controller: _contactCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              hintText: 'e.g. Rohan Mendis'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Enter contact name'
                                  : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormCard(
                      title: 'Contact info',
                      children: [
                        _FieldLabel('Phone *'),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              hintText: '+94 11 234 5678'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Enter phone number'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Email'),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                              hintText: 'vendor@example.com'),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Address'),
                        TextFormField(
                          controller: _addressCtrl,
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                              hintText: 'Street, City'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormCard(
                      title: 'Notes',
                      children: [
                        TextFormField(
                          controller: _notesCtrl,
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                              hintText:
                                  'Delivery schedule, minimum order, etc. (optional)'),
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
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.inkTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(0, 52),
                            ),
                            child: Text(
                              _isEditing
                                  ? 'Save Changes'
                                  : 'Add Supplier',
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
            color: AppColors.hairline.withAlpha(150), width: 1.5),
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
      child: Text(text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.bold,
              fontSize: 13)),
    );
  }
}
