import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

import '../../data/customers_repository.dart';
import '../../../../core/api/api_helper.dart';

class AddCustomerView extends StatefulWidget {
  const AddCustomerView({super.key, this.orgId});

  final String? orgId;

  @override
  State<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  final _customersRepo = CustomersRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final dto = CreateCustomerDto(
        orgId: widget.orgId ?? '00000000-0000-0000-0000-000000000000',
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text.trim() : null,
        address: _addressCtrl.text.isNotEmpty ? _addressCtrl.text.trim() : null,
      );

      final response = await _customersRepo.createCustomer(dto);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.isSuccess) {
        ApiHelper.showSuccessSnackBar(context, 'Customer added successfully.');
        Navigator.of(context).pop(true);
      } else {
        ApiHelper.showErrorSnackBar(
          context,
          response.errorMessage ?? context.tr('common.error'),
        );
      }
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
          context.tr('customers.add_customer'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
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
                      title: context.tr('customers.customer_details'),
                      children: [
                        _FieldLabel(context.tr('customers.name')),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(hintText: context.tr('customers.name_hint')),
                          validator: (v) => (v == null || v.trim().isEmpty) ? context.tr('customers.name_required') : null,
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(context.tr('customers.phone')),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(hintText: context.tr('customers.phone_hint')),
                          validator: (v) => (v == null || v.trim().isEmpty) ? context.tr('customers.phone_required') : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormCard(
                      title: context.tr('customers.contact_and_address'),
                      children: [
                        _FieldLabel(context.tr('customers.email')),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(hintText: context.tr('customers.email_hint')),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel(context.tr('customers.address')),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: InputDecoration(hintText: context.tr('customers.address_hint')),
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
                              side: const BorderSide(color: AppColors.hairline, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                    context.tr('customers.save_customer'),
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
        border: Border.all(color: AppColors.hairline.withAlpha(150), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
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
