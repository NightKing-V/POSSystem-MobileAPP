import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/supplier_mock_data.dart';

/// Reusable vendor list card used in SuppliersListView.
class SupplierCard extends StatelessWidget {
  const SupplierCard({
    super.key,
    required this.vendor,
    required this.linkedProductCount,
    required this.onTap,
  });

  final Vendor vendor;
  final int linkedProductCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.hairline.withAlpha(150), width: 1.5),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.inkTeal.withAlpha(18),
              child: Text(
                vendor.name.isNotEmpty
                    ? vendor.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.inkTeal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      _StatusDot(isActive: vendor.isActive),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    vendor.contactPerson,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate),
                  ),
                  Text(
                    vendor.phone,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate),
                  ),
                  const SizedBox(height: 8),
                  _ProductCountChip(count: linkedProductCount),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.slate, size: 18),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF16A34A)
                : AppColors.slate,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive
                ? const Color(0xFF16A34A)
                : AppColors.slate,
          ),
        ),
      ],
    );
  }
}

class _ProductCountChip extends StatelessWidget {
  const _ProductCountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.inkTeal.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$count linked ${count == 1 ? 'product' : 'products'}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.inkTeal,
        ),
      ),
    );
  }
}
