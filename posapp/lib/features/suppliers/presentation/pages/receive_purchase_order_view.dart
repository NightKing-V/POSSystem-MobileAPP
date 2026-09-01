import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/supplier_mock_data.dart';

class ReceivePurchaseOrderView extends StatefulWidget {
  const ReceivePurchaseOrderView({super.key, required this.order});

  final PurchaseOrder order;

  @override
  State<ReceivePurchaseOrderView> createState() =>
      _ReceivePurchaseOrderViewState();
}

class _ReceivePurchaseOrderViewState
    extends State<ReceivePurchaseOrderView> {
  late final List<_ReceiveRow> _rows;
  late PurchaseOrderStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
    _rows = widget.order.items
        .map((item) => _ReceiveRow(
              item: item,
              receivedCtrl: TextEditingController(
                  text: item.receivedQty.toString()),
              isMissing: item.isMissing,
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  bool get _allReceived =>
      _rows.every((r) =>
          (int.tryParse(r.receivedCtrl.text) ?? 0) >= r.item.orderedQty);

  bool get _anyReceived =>
      _rows.any((r) => (int.tryParse(r.receivedCtrl.text) ?? 0) > 0);

  void _confirm() {
    final allDone = _allReceived;
    setState(() {
      _status = allDone
          ? PurchaseOrderStatus.received
          : PurchaseOrderStatus.partiallyReceived;
      widget.order.status = _status;
      for (final r in _rows) {
        r.item.receivedQty =
            int.tryParse(r.receivedCtrl.text) ?? r.item.receivedQty;
        r.item.isMissing = r.isMissing;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(allDone
            ? '${widget.order.id} marked as Received.'
            : '${widget.order.id} marked as Partially Received.'),
        backgroundColor: allDone
            ? const Color(0xFF16A34A)
            : const Color(0xFFD97706),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Receive Goods',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text(widget.order.id,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12)),
          ],
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                // ── Info card ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: _InfoCard(
                    order: widget.order,
                    currentStatus: _status,
                  ),
                ),
                const SizedBox(height: 12),
                // ── Column headers ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                  child: Row(
                    children: [
                      const Expanded(
                          child: Text('Product',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.slate))),
                      const SizedBox(
                        width: 60,
                        child: Text('Ordered',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppColors.slate)),
                      ),
                      const SizedBox(
                        width: 70,
                        child: Text('Received',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppColors.slate)),
                      ),
                      const SizedBox(
                        width: 64,
                        child: Text('Missing',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppColors.slate)),
                      ),
                    ],
                  ),
                ),
                // ── Items list ────────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: _rows.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) => _ReceiveItemRow(
                      row: _rows[i],
                      onChanged: () => setState(() {}),
                      onMissingToggle: (v) =>
                          setState(() => _rows[i].isMissing = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _ConfirmBar(
        allReceived: _allReceived,
        anyReceived: _anyReceived,
        onConfirm: _confirm,
      ),
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _ReceiveRow {
  _ReceiveRow({
    required this.item,
    required this.receivedCtrl,
    required this.isMissing,
  });

  final PurchaseOrderItem item;
  final TextEditingController receivedCtrl;
  bool isMissing;

  void dispose() => receivedCtrl.dispose();
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.order, required this.currentStatus});

  final PurchaseOrder order;
  final PurchaseOrderStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.hairline.withAlpha(150), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vendorName(order.vendorId),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  'Expected: ${order.expectedDate.day}/${order.expectedDate.month}/${order.expectedDate.year}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.slate),
                ),
              ],
            ),
          ),
          _StatusChip(status: currentStatus),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final PurchaseOrderStatus status;

  static Color _color(PurchaseOrderStatus s) {
    switch (s) {
      case PurchaseOrderStatus.sent:
        return const Color(0xFF2563EB);
      case PurchaseOrderStatus.partiallyReceived:
        return const Color(0xFFD97706);
      case PurchaseOrderStatus.received:
        return const Color(0xFF16A34A);
      default:
        return AppColors.slate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withAlpha(60), width: 1),
      ),
      child: Text(status.label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: c)),
    );
  }
}

class _ReceiveItemRow extends StatelessWidget {
  const _ReceiveItemRow({
    required this.row,
    required this.onChanged,
    required this.onMissingToggle,
  });

  final _ReceiveRow row;
  final VoidCallback onChanged;
  final ValueChanged<bool> onMissingToggle;

  @override
  Widget build(BuildContext context) {
    final received =
        int.tryParse(row.receivedCtrl.text) ?? 0;
    final short = received < row.item.orderedQty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: row.isMissing
            ? AppColors.error.withAlpha(8)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: row.isMissing
              ? AppColors.error.withAlpha(60)
              : AppColors.hairline.withAlpha(150),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(row.item.product.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          // Ordered qty
          SizedBox(
            width: 60,
            child: Center(
              child: Text('${row.item.orderedQty}',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.slate)),
            ),
          ),
          // Received qty field
          SizedBox(
            width: 70,
            child: TextField(
              controller: row.receivedCtrl,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 6),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: short
                        ? const Color(0xFFD97706)
                        : AppColors.hairline,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(
                      color: AppColors.inkTeal, width: 1.5),
                ),
              ),
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          // Missing checkbox
          SizedBox(
            width: 64,
            child: Checkbox(
              value: row.isMissing,
              onChanged: (v) => onMissingToggle(v ?? false),
              activeColor: AppColors.error,
              side: const BorderSide(color: AppColors.slate, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.allReceived,
    required this.anyReceived,
    required this.onConfirm,
  });

  final bool allReceived;
  final bool anyReceived;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final label = allReceived
        ? 'Mark as Received'
        : 'Mark as Partially Received';
    final color = allReceived
        ? const Color(0xFF16A34A)
        : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(
                color: AppColors.hairline.withAlpha(150), width: 1.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: anyReceived ? onConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.hairline,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
