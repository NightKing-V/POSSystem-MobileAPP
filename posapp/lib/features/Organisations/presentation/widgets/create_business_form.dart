import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/form_field_label.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../data/orgs_repository.dart';
import '../validators/org_validators.dart';

class CreateBusinessForm extends StatefulWidget {
  const CreateBusinessForm({
    super.key,
    required this.onSuccess,
    this.onCancel,
    this.submitButtonText,
  });

  final VoidCallback onSuccess;
  final VoidCallback? onCancel;
  final String? submitButtonText;

  @override
  State<CreateBusinessForm> createState() => _CreateBusinessFormState();
}

class _CreateBusinessFormState extends State<CreateBusinessForm> {
  final _orgsRepository = OrgsRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;

  String _selectedCategoryType = 'Retail';
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  List<Map<String, dynamic>> _backendCategories = [];

  static const _defaultCategoryOptions = [
    {'name': 'Retail', 'icon': Icons.storefront_outlined},
    {'name': 'Grocery', 'icon': Icons.local_grocery_store_outlined},
    {'name': 'Apparel & Clothing', 'icon': Icons.checkroom_outlined},
    {'name': 'Restaurant / Cafe', 'icon': Icons.restaurant_outlined},
    {'name': 'Pharmacy', 'icon': Icons.local_pharmacy_outlined},
    {'name': 'Electronics', 'icon': Icons.devices_other_outlined},
    {'name': 'Service & Repairs', 'icon': Icons.handyman_outlined},
    {'name': 'Other', 'icon': Icons.business_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final res = await _orgsRepository.fetchBusinessCategories();
      if (mounted && res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          _backendCategories = res.data!;
          if (_backendCategories.isNotEmpty) {
            _selectedCategoryId = _backendCategories.first['id']?.toString();
            _selectedCategoryType = _backendCategories.first['type']?.toString() ??
                _backendCategories.first['name']?.toString() ??
                'Retail';
          }
        });
      }
    } catch (_) {
      // Fallback to presets
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final dto = CreateOrgDto(
      businessName: _nameCtrl.text.trim(),
      businessType: _selectedCategoryType,
      businessCategoryId: _selectedCategoryId,
      address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
    );

    final response = await _orgsRepository.createOrganization(dto);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      ApiHelper.showSuccessSnackBar(context, context.tr('orgs.created_success'));
      widget.onSuccess();
    } else {
      ApiHelper.showErrorSnackBar(
        context,
        response.errorMessage ?? context.tr('common.error'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('orgs.business_details'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 16),
                AppTextFormField(
                  label: context.tr('orgs.store_name'),
                  isRequired: true,
                  controller: _nameCtrl,
                  hintText: context.tr('orgs.store_name_hint'),
                  prefixIcon: const Icon(Icons.storefront_outlined, color: AppColors.slate, size: 20),
                  validator: OrgValidators.businessName.validate,
                ),
                const SizedBox(height: 16),
                FormFieldLabel(
                  label: context.tr('orgs.business_category'),
                  isRequired: true,
                ),
                if (_isLoadingCategories)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  )
                else if (_backendCategories.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined, color: AppColors.slate, size: 20),
                    ),
                    items: _backendCategories.map((c) {
                      final id = c['id']?.toString() ?? '';
                      final name = c['type']?.toString() ?? c['name']?.toString() ?? 'General';
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCategoryId = val;
                          final found = _backendCategories.firstWhere(
                            (e) => e['id']?.toString() == val,
                            orElse: () => {},
                          );
                          _selectedCategoryType = found['type']?.toString() ??
                              found['name']?.toString() ??
                              'Retail';
                        });
                      }
                    },
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryType,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined, color: AppColors.slate, size: 20),
                    ),
                    items: _defaultCategoryOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt['name'] as String,
                        child: Row(
                          children: [
                            Icon(opt['icon'] as IconData, size: 18, color: AppColors.inkTeal),
                            const SizedBox(width: 10),
                            Text(opt['name'] as String),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategoryType = val);
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('orgs.branch_and_contact'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 16),
                AppTextFormField(
                  label: context.tr('orgs.physical_address'),
                  isRequired: false,
                  controller: _addressCtrl,
                  hintText: context.tr('orgs.physical_address_hint'),
                  prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.slate, size: 20),
                  validator: OrgValidators.address.validate,
                ),
                const SizedBox(height: 16),
                FormFieldLabel(
                  label: context.tr('orgs.contact_phone'),
                ),
                PhoneInputField(
                  controller: _phoneCtrl,
                  isRequired: false,
                  hintText: context.tr('orgs.contact_phone_hint'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (widget.onCancel != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : widget.onCancel,
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
              ],
              Expanded(
                flex: widget.onCancel != null ? 2 : 1,
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
                          widget.submitButtonText ?? context.tr('orgs.create_button'),
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
    );
  }
}
