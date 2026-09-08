import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/domain/mock_data.dart';
import '../../../inventory/domain/models/product.dart';
import '../../domain/models/supplier_mock_data.dart';
import '../widgets/po_line_item_row.dart';
import '../widgets/po_product_picker_sheet.dart';

/// Clean screen for creating or editing purchase orders.
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
  final List<PoLineItem> _lines = [];

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
        _lines.add(
          PoLineItem(
            product: item.product,
            qtyCtrl: TextEditingController(text: item.orderedQty.toString()),
            costCtrl:
                TextEditingController(text: item.unitCost.toStringAsFixed(2)),
          ),
        );
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
                (double.tryParse(l.costCtrl.text) ?? 0.0),
      );

  void _addLine(Product p) {
    setState(() {
      _lines.add(
        PoLineItem(
          product: p,
          qtyCtrl: TextEditingController(text: '1'),
          costCtrl: TextEditingController(text: p.price.toStringAsFixed(2)),
        ),
      );
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
                color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Order Sent!',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              'The purchase order has been sent\nto ${_selectedVendorId != null ? vendorName(_selectedVendorId!) : 'the supplier'}.',
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
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
                          .map(
                            (v) => DropdownMenuItem(
                              value: v.id,
                              child: Text(v.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedVendorId = v),
                    ),
                    const SizedBox(height: 16),
                    _Label('Delivery Location *'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLocationId,
                      decoration: const InputDecoration(),
                      items: mockLocations
                          .map(
                            (l) => DropdownMenuItem(
                              value: l.id,
                              child: Text(l.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedLocationId = v),
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
                            color: AppColors.hairline,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: AppColors.slate,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${_expectedDate.day}/${_expectedDate.month}/${_expectedDate.year}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Products / Line items ─────────────────────────────────
                _SectionCard(
                  title: 'Line items',
                  children: [
                    if (_lines.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 36,
                              color: AppColors.slate.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No products added yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.slate),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _lines.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => PoLineItemRow(
                          line: _lines[i],
                          onRemove: () => _removeLine(i),
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add product'),
                      onPressed: () => PoProductPickerSheet.show(
                        context,
                        onSelect: _addLine,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.inkTeal,
                        side: const BorderSide(
                          color: AppColors.inkTeal,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Order Total summary card ──────────────────────────────
                _OrderTotalCard(total: _orderTotal),
                const SizedBox(height: 16),

                // ── Note / Remarks ────────────────────────────────────────
                _SectionCard(
                  title: 'Notes & Instructions',
                  children: [
                    TextFormField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Internal note (optional)',
                      ),
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

class _OrderTotalCard extends StatelessWidget {
  const _OrderTotalCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inkTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.inkTeal.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Order Total',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 14),
          ),
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
            color: AppColors.hairline.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate,
                side: const BorderSide(
                  color: AppColors.hairline,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 50),
              ),
              child: const Text(
                'Save as Draft',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text(
                'Send Order',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
          color: AppColors.hairline.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontSize: 15),
          ),
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
              fontSize: 13,
            ),
      ),
    );
  }
}
