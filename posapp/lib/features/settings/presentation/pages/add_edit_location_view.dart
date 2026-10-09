import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/form_field_label.dart';
import '../../../../core/widgets/phone_input_field.dart';
import '../../../Organisations/data/orgs_repository.dart';
import '../../../inventory/data/inventory_repository.dart';
import '../validators/location_validators.dart';

class AddEditLocationView extends StatefulWidget {
  const AddEditLocationView({super.key, this.location, this.isModal = true});

  final LocationProps? location;
  final bool isModal;

  @override
  State<AddEditLocationView> createState() => _AddEditLocationViewState();
}

class _AddEditLocationViewState extends State<AddEditLocationView> {
  final _inventoryRepo = InventoryRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isSaving = false;

  bool get _isEditing => widget.location != null;

  @override
  void initState() {
    super.initState();
    final loc = widget.location;
    _nameCtrl = TextEditingController(text: loc?.name ?? '');
    _addressCtrl = TextEditingController(text: loc?.address ?? '');
    _phoneCtrl = TextEditingController(text: loc?.phone ?? '');
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

    setState(() => _isSaving = true);

    ApiResponse<Map<String, dynamic>> res;

    if (_isEditing) {
      res = await _inventoryRepo.updateLocation(widget.location!.id, {
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
    } else {
      final dto = CreateInventoryLocationDto(
        name: _nameCtrl.text.trim(),
        type: 'BRANCH',
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      res = await _inventoryRepo.createLocation(dto);
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (res.isSuccess) {
      Navigator.of(context).pop(true);
      ApiHelper.showSuccessSnackBar(
        context,
        _isEditing
            ? context.tr('common.updated_success')
            : context.tr('common.created_success'),
      );
    } else {
      ApiHelper.showErrorSnackBar(
        context,
        res.errorMessage ?? context.tr('common.error'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formFields = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('locations.location_details'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              label: context.tr('locations.branch_name'),
              isRequired: true,
              controller: _nameCtrl,
              hintText: context.tr('locations.branch_name_hint'),
              validator: LocationValidators.branchName.validate,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: context.tr('common.address'),
              isRequired: false,
              controller: _addressCtrl,
              maxLines: 2,
              hintText: context.tr('locations.address_hint'),
              validator: LocationValidators.address.validate,
            ),
            const SizedBox(height: 16),
            FormFieldLabel(label: context.tr('common.phone')),
            PhoneInputField(
              controller: _phoneCtrl,
              isRequired: false,
              hintText: context.tr('locations.phone_hint'),
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
                side: const BorderSide(color: AppColors.hairline, width: 1.5),
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
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 48),
              ),
              child: _isSaving
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
                          : context.tr('locations.add_location'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
        Flexible(child: formFields),
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
          _isEditing
              ? context.tr('locations.edit_location')
              : context.tr('locations.add_location'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: content),
    );
  }
}
