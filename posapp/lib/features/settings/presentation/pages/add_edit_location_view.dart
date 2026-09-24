import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../Organisations/data/orgs_repository.dart';

class AddEditLocationView extends StatefulWidget {
  const AddEditLocationView({
    super.key,
    this.location,
    this.isModal = true,
  });

  final LocationProps? location;
  final bool isModal;

  @override
  State<AddEditLocationView> createState() => _AddEditLocationViewState();
}

class _AddEditLocationViewState extends State<AddEditLocationView> {
  final _orgsRepo = OrgsRepository();
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

    final dto = CreateOrgDto(
      businessName: _nameCtrl.text.trim(),
      businessType: 'BRANCH',
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    final res = await _orgsRepo.createOrganization(dto);
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (res.isSuccess) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Location updated.' : 'Location created.'),
          backgroundColor: AppColors.inkTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.errorMessage ?? 'Failed to save location.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
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
              'Location Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
            ),
            const SizedBox(height: 14),
            _Label('Name *'),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'e.g. Main Branch, Outlet 2',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a name'
                  : null,
            ),
            const SizedBox(height: 16),
            _Label('Address *'),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Street, City',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter an address'
                  : null,
            ),
            const SizedBox(height: 16),
            _Label('Phone Number'),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+94 77 123 4567',
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
                    child: const Text('Cancel'),
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
                      minimumSize: const Size(0, 52),
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
                            _isEditing ? 'Save Changes' : 'Create Location',
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
          _isEditing ? 'Edit Location' : 'Add Location',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: formBody),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

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
