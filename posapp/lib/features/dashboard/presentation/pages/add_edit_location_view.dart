import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/mock_data.dart';

class AddEditLocationView extends StatefulWidget {
  const AddEditLocationView({super.key, this.location});

  final MockLocation? location;

  @override
  State<AddEditLocationView> createState() => _AddEditLocationViewState();
}

class _AddEditLocationViewState extends State<AddEditLocationView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _taxCtrl;
  late String _selectedTimezone;
  late String _selectedCurrency;

  static const _timezones = [
    'Asia/Colombo',
    'Asia/Kolkata',
    'Asia/Dubai',
    'Europe/London',
    'America/New_York',
  ];

  static const _currencies = ['LKR', 'INR', 'AED', 'GBP', 'USD'];

  bool get _isEditing => widget.location != null;

  @override
  void initState() {
    super.initState();
    final loc = widget.location;
    _nameCtrl = TextEditingController(text: loc?.name ?? '');
    _addressCtrl = TextEditingController(text: loc?.address ?? '');
    _taxCtrl = TextEditingController(
        text: loc != null ? loc.taxRate.toStringAsFixed(0) : '15');
    _selectedTimezone = loc?.timezone ?? _timezones.first;
    _selectedCurrency = loc?.currency ?? _currencies.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditing ? 'Location updated.' : 'Location created.'),
          backgroundColor: AppColors.inkTeal,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          _isEditing ? 'Edit Location' : 'Add Location',
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
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
                      title: 'Location details',
                      children: [
                        _Label('Name *'),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration:
                              const InputDecoration(hintText: 'e.g. Main Branch'),
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
                          decoration:
                              const InputDecoration(hintText: 'Street, City'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter an address'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _Label('Tax Rate (%)'),
                        TextFormField(
                          controller: _taxCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(hintText: '15', suffixText: '%'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _FormCard(
                      title: 'Regional settings',
                      children: [
                        _Label('Timezone'),
                        DropdownButtonFormField<String>(
                          value: _selectedTimezone,
                          items: _timezones
                              .map((tz) => DropdownMenuItem(
                                  value: tz, child: Text(tz)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedTimezone = v!),
                          decoration: const InputDecoration(),
                        ),
                        const SizedBox(height: 16),
                        _Label('Currency'),
                        DropdownButtonFormField<String>(
                          value: _selectedCurrency,
                          items: _currencies
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCurrency = v!),
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.inkTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          _isEditing ? 'Save Changes' : 'Create Location',
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
        border:
            Border.all(color: AppColors.hairline.withOpacity(0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 16)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
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
            fontSize: 13),
      ),
    );
  }
}
