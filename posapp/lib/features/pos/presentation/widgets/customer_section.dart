import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customers/data/customers_repository.dart';

/// Collapsible customer lookup accordion section connected to Customers API.
class CustomerSection extends StatefulWidget {
  const CustomerSection({
    super.key,
    required this.onDismiss,
    this.selectedCustomer,
    required this.onCustomerSelected,
    this.orgId,
  });

  final VoidCallback onDismiss;
  final CustomerProps? selectedCustomer;
  final ValueChanged<CustomerProps?> onCustomerSelected;
  final String? orgId;

  @override
  State<CustomerSection> createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<CustomerSection> {
  final _customersRepo = CustomersRepository();
  final TextEditingController _ctrl = TextEditingController();
  List<CustomerProps> _allCustomers = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.selectedCustomer != null) {
      _ctrl.text = widget.selectedCustomer!.fullName;
    }
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    final res = await _customersRepo.fetchCustomers(orgId: widget.orgId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res.isSuccess && res.data != null) {
        _allCustomers = res.data!;
      }
    });
  }

  List<CustomerProps> get _filtered {
    if (_query.trim().isEmpty) return _allCustomers.take(5).toList();
    final q = _query.toLowerCase();
    return _allCustomers
        .where((c) =>
            c.fullName.toLowerCase().contains(q) ||
            c.phone.contains(q) ||
            (c.email != null && c.email!.toLowerCase().contains(q)))
        .toList();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWalkIn = widget.selectedCustomer == null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.hairline.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.slate),
              const SizedBox(width: 5),
              Text(
                'Customer',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 12),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.inkTeal),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onDismiss,
                child: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 18,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _CustomerChip(
                label: 'Walk-in',
                selected: isWalkIn,
                onTap: () {
                  widget.onCustomerSelected(null);
                  _ctrl.clear();
                  setState(() => _query = '');
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search customer name or phone…',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    suffixIcon: _ctrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _ctrl.clear();
                              widget.onCustomerSelected(null);
                              setState(() => _query = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
          if (widget.selectedCustomer != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.inkTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 14, color: AppColors.inkTeal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${widget.selectedCustomer!.fullName} · ${widget.selectedCustomer!.phone}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkTeal),
                    ),
                  ),
                  if (widget.selectedCustomer!.isLoyaltyMember)
                    Text(
                      '${widget.selectedCustomer!.loyaltyPoints} pts',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkTeal),
                    ),
                ],
              ),
            ),
          ] else if (_query.isNotEmpty && _filtered.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.hairline),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filtered.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.hairline),
                itemBuilder: (context, i) {
                  final c = _filtered[i];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(c.fullName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text(c.phone, style: const TextStyle(fontSize: 11, color: AppColors.slate)),
                    trailing: c.isLoyaltyMember
                        ? Text('${c.loyaltyPoints} pts', style: const TextStyle(fontSize: 11, color: AppColors.inkTeal))
                        : null,
                    onTap: () {
                      _ctrl.text = c.fullName;
                      widget.onCustomerSelected(c);
                      setState(() => _query = '');
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CustomerChip extends StatelessWidget {
  const _CustomerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.inkTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.inkTeal : AppColors.hairline,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.slate,
          ),
        ),
      ),
    );
  }
}

/// Compact chip shown when the customer section is collapsed.
class CustomerToggleChip extends StatelessWidget {
  const CustomerToggleChip({
    super.key,
    required this.onTap,
    this.selectedCustomer,
  });

  final VoidCallback onTap;
  final CustomerProps? selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final label = selectedCustomer != null ? selectedCustomer!.fullName : 'Walk-in Customer';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.hairline, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedCustomer != null ? Icons.person : Icons.person_outline_rounded,
              size: 14,
              color: selectedCustomer != null ? AppColors.inkTeal : AppColors.slate,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: selectedCustomer != null ? AppColors.inkTeal : null,
                    fontWeight: selectedCustomer != null ? FontWeight.w600 : null,
                  ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 14, color: AppColors.slate),
          ],
        ),
      ),
    );
  }
}
