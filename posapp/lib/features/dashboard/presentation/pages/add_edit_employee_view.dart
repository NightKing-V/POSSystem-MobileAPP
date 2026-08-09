import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/mock_data.dart';

class AddEditEmployeeView extends StatefulWidget {
  const AddEditEmployeeView({super.key, this.employee});

  final MockEmployee? employee;

  @override
  State<AddEditEmployeeView> createState() => _AddEditEmployeeViewState();
}

class _AddEditEmployeeViewState extends State<AddEditEmployeeView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late String _selectedLocationId;
  late String _selectedPermSetId;

  // PIN state
  final List<TextEditingController> _pinCtrls =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _confirmCtrls =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _pinFoci = List.generate(4, (_) => FocusNode());
  final List<FocusNode> _confirmFoci = List.generate(4, (_) => FocusNode());
  String _pinError = '';

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _contactCtrl = TextEditingController(text: e?.contact ?? '');
    _selectedLocationId = e?.locationId ?? mockLocations.first.id;
    _selectedPermSetId =
        e?.permissionSetId ?? mockPermissionSets.first.id;
    if (_isEditing && e!.pin.length == 4) {
      for (int i = 0; i < 4; i++) {
        _pinCtrls[i].text = e.pin[i];
        _confirmCtrls[i].text = e.pin[i];
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    for (final c in [..._pinCtrls, ..._confirmCtrls]) {
      c.dispose();
    }
    for (final f in [..._pinFoci, ..._confirmFoci]) {
      f.dispose();
    }
    super.dispose();
  }

  String get _pin => _pinCtrls.map((c) => c.text).join();
  String get _confirmPin => _confirmCtrls.map((c) => c.text).join();

  void _save() {
    setState(() => _pinError = '');
    if (!_formKey.currentState!.validate()) return;
    if (_pin.length < 4) {
      setState(() => _pinError = 'Please enter a 4-digit PIN');
      return;
    }
    if (_pin != _confirmPin) {
      setState(() => _pinError = 'PINs do not match');
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            _isEditing ? 'Employee updated.' : 'Employee added.'),
        backgroundColor: AppColors.inkTeal,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
          _isEditing ? 'Edit Employee' : 'Add Employee',
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
                    // Details card
                    _SectionCard(
                      title: 'Employee details',
                      children: [
                        _Label('Full Name *'),
                        TextFormField(
                          controller: _nameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                              hintText: 'e.g. Ashan Perera'),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Enter name'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _Label('Contact Number'),
                        TextFormField(
                          controller: _contactCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              hintText: '+94 71 234 5678'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Assignment card
                    _SectionCard(
                      title: 'Assignment',
                      children: [
                        _Label('Location *'),
                        DropdownButtonFormField<String>(
                          value: _selectedLocationId,
                          items: mockLocations
                              .map((l) => DropdownMenuItem(
                                  value: l.id, child: Text(l.name)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedLocationId = v!),
                          decoration: const InputDecoration(),
                        ),
                        const SizedBox(height: 16),
                        _Label('Permission Set *'),
                        DropdownButtonFormField<String>(
                          value: _selectedPermSetId,
                          items: mockPermissionSets
                              .map((p) => DropdownMenuItem(
                                  value: p.id, child: Text(p.name)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedPermSetId = v!),
                          decoration: const InputDecoration(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // PIN card
                    _SectionCard(
                      title: 'POS PIN',
                      children: [
                        _Label('Set PIN'),
                        _PinRow(
                            controllers: _pinCtrls, focusNodes: _pinFoci),
                        const SizedBox(height: 16),
                        _Label('Confirm PIN'),
                        _PinRow(
                            controllers: _confirmCtrls,
                            focusNodes: _confirmFoci),
                        if (_pinError.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(_pinError,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 12)),
                        ],
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
                          _isEditing ? 'Save Changes' : 'Add Employee',
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

class _PinRow extends StatelessWidget {
  const _PinRow({required this.controllers, required this.focusNodes});

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
          child: SizedBox(
            width: 52,
            child: TextField(
              controller: controllers[i],
              focusNode: focusNodes[i],
              obscureText: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 20),
              decoration: const InputDecoration(
                counterText: '',
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) {
                if (v.isNotEmpty && i < 3) {
                  FocusScope.of(context)
                      .requestFocus(focusNodes[i + 1]);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

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
            color: AppColors.hairline.withOpacity(0.6), width: 1.5),
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
