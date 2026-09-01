import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/supplier_mock_data.dart';
import '../../../inventory/domain/models/product.dart';
import '../../../dashboard/domain/mock_data.dart';

class CreateEditPurchaseOrderView extends StatefulWidget {
  const CreateEditPurchaseOrderView({super.key, this.vendor, this.order});

  final Vendor? vendor;
  final PurchaseOrder? order;

  @override
  State<CreateEditPurchaseOrderView> createState() =>
      _CreateEditPurchaseOrderViewState();
}

class _CreateEditPurchaseOrderViewState
    extends State<CreateEditPurchaseOrderView> {
  final _noteCtrl = TextEditingController();
  String? _selectedVendorId;
  String? _selectedLocationId;
  DateTime _expectedDate = DateTime.now().add(const Duration(days: 7));
  final List<_LineItem> _lines = [];

  bool get _isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    if (widget.vendor != null) _selectedVendorId = widget.vendor!.id;
    _selectedLocationId = mockLocations.first.id;
    if (_isEditing) {
      final o = widget.order!;
      _selectedVendorId = o.vendorId;
      _selectedLocationId = o.locationId;
      _expectedDate = o.expectedDate;
      _noteCtrl.text = o.note;
      for (final item in o.items) {
        _lines.add(_LineItem(
          product: item.product,
          qtyCtrl: TextEditingController(
              text: item.orderedQty.toString()),
          costCtrl: TextEditingController(
              text: item.unitCost.toStringAsFixed(2)),
        ));
      }
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  double get _orderTotal => _lines.fold(
      0.0,
      (s, l) =>
          s +
          (int.tryParse(l.qtyCtrl.text) ?? 0) *
              (double.tryParse(l.costCtrl.text) ?? 0.0));

  void _addLine(Product p) {
    setState(() {
      _lines.add(_LineItem(
        product: p,
        qtyCtrl: TextEditingController(text: '1'),
        costCtrl: TextEditingController(
            text: p.price.toStringAsFixed(2)),
      ));
    });
  }

  void _removeLine(int i) => setState(() {
        _lines[i].dispose();
        _lines.removeAt(i);
      });

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _expectedDate = picked);
  }

  void _saveDraft() {
    Navigator.of(context).pop();
    _showSnackbar('Purchase order saved as draft.');
  }

  void _send() {
    if (_lines.isEmpty) {
      _showSnackbar('Add at least one line item.', isError: true);
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Color(0xFF2563EB), size: 28),
            ),
            const SizedBox(height: 14),
            Text('Order Sent!',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'The purchase order has been sent\nto ${_selectedVendorId != null ? vendorName(_selectedVendorId!) : 'the supplier'}.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 13),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Done',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.inkTeal,
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
          _isEditing ? 'Edit Purchase Order' : 'New Purchase Order',
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
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(24, 16, 24, 120),
              children: [
                // ── Header card (vendor, location, date) ──────────────────
                _SectionCard(
                  title: 'Order details',
                  children: [
                    _Label('Vendor *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedVendorId,
                      hint: const Text('Select a vendor'),
                      decoration: const InputDecoration(),
                      items: mockVendors
                          .map((v) => DropdownMenuItem(
                              value: v.id, child: Text(v.name)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedVendorId = v),
                    ),
                    const SizedBox(height: 16),
                    _Label('Delivery Location *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLocationId,
                      decoration: const InputDecoration(),
                      items: mockLocations
                          .map((l) => DropdownMenuItem(
                              value: l.id, child: Text(l.name)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedLocationId = v),
                    ),
                    const SizedBox(height: 16),
                    _Label('Expected Delivery Date'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.hairline, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 16, color: AppColors.slate),
                            const SizedBox(width: 10),
                            Text(
                              '${_expectedDate.day}/${_expectedDate.month}/${_expectedDate.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.ink),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Line items ────────────────────────────────────────────
                _SectionCard(
                  title: 'Line Items',
                  children: [
                    if (_lines.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text('No items added yet.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 12)),
                      ),
                    ..._lines.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LineItemRow(
                            line: e.value,
                            onRemove: () => _removeLine(e.key),
                            onChanged: () => setState(() {}),
                          ),
                        )),
                    _AddProductButton(onSelect: _addLine),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Order total ───────────────────────────────────────────
                if (_lines.isNotEmpty) ...[
                  _OrderTotalCard(total: _orderTotal),
                  const SizedBox(height: 16),
                ],

                // ── Note ─────────────────────────────────────────────────
                _SectionCard(
                  title: 'Note',
                  children: [
                    TextFormField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                          hintText: 'Internal note (optional)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _ActionBar(
        onDraft: _saveDraft,
        onSend: _send,
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _LineItem {
  _LineItem({
    required this.product,
    required this.qtyCtrl,
    required this.costCtrl,
  });

  final Product product;
  final TextEditingController qtyCtrl;
  final TextEditingController costCtrl;

  double get lineTotal =>
      (int.tryParse(qtyCtrl.text) ?? 0) *
      (double.tryParse(costCtrl.text) ?? 0.0);

  void dispose() {
    qtyCtrl.dispose();
    costCtrl.dispose();
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({
    required this.line,
    required this.onRemove,
    required this.onChanged,
  });

  final _LineItem line;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.hairline.withAlpha(150), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(line.product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MiniField(
                  controller: line.qtyCtrl,
                  label: 'Qty',
                  numeric: true,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _MiniField(
                  controller: line.costCtrl,
                  label: 'Unit Cost (Rs.)',
                  decimal: true,
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.slate)),
                    Text('Rs. ${line.lineTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.inkTeal)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniField extends StatelessWidget {
  const _MiniField({
    required this.controller,
    required this.label,
    required this.onChanged,
    this.numeric = false,
    this.decimal = false,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final bool numeric;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.slate)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: decimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number,
          inputFormatters: [
            if (numeric) FilteringTextInputFormatter.digitsOnly,
            if (decimal)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _AddProductButton extends StatelessWidget {
  const _AddProductButton({required this.onSelect});

  final ValueChanged<Product> onSelect;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.add, size: 16),
      label: const Text('Add product'),
      onPressed: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ProductPickerSheet(onSelect: onSelect),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.inkTeal,
        side: const BorderSide(color: AppColors.inkTeal, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(double.infinity, 44),
      ),
    );
  }
}

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet({required this.onSelect});

  final ValueChanged<Product> onSelect;

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  String _q = '';

  List<Product> get _filtered {
    if (_q.isEmpty) return Product.mockProducts;
    return Product.mockProducts
        .where((p) => p.name.toLowerCase().contains(_q.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(
                  hintText: 'Search products…',
                  prefixIcon:
                      Icon(Icons.search_rounded, color: AppColors.slate, size: 20),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (_, i) => ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  tileColor: AppColors.paper,
                  title: Text(_filtered[i].name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  trailing: Text(
                      'Rs. ${_filtered[i].price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: AppColors.inkTeal,
                          fontWeight: FontWeight.bold)),
                  onTap: () {
                    widget.onSelect(_filtered[i]);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTotalCard extends StatelessWidget {
  const _OrderTotalCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inkTeal.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.inkTeal.withAlpha(40), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Order Total',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 14)),
          Text(
            'Rs. ${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 22,
                  color: AppColors.inkTeal,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.onDraft, required this.onSend});

  final VoidCallback onDraft;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(
                color: AppColors.hairline.withAlpha(150), width: 1.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate,
                side: const BorderSide(
                    color: AppColors.hairline, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(0, 50),
              ),
              child: const Text('Save as Draft',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Send Order',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(0, 50),
              ),
            ),
          ),
        ],
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

class _Label extends StatelessWidget {
  const _Label(this.text);

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
