import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Column definition for [ManagementDataTable].
class ManagementTableColumn {
  const ManagementTableColumn({
    required this.label,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
  });

  final String label;
  final int flex;
  final double? width;
  final Alignment alignment;
}

/// Row data model for [ManagementDataTable].
class ManagementTableRow {
  const ManagementTableRow({
    required this.cells,
    this.onTap,
  });

  final List<Widget> cells;
  final VoidCallback? onTap;
}

/// A clean, modern enterprise-grade Data Table widget for Desktop views.
/// Features sleek headers, subtle hover interactions, and responsive column sizing.
class ManagementDataTable extends StatelessWidget {
  const ManagementDataTable({
    super.key,
    required this.columns,
    required this.itemCount,
    required this.rowBuilder,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 40),
  });

  final List<ManagementTableColumn> columns;
  final int itemCount;
  final ManagementTableRow Function(BuildContext context, int index) rowBuilder;
  final EdgeInsets padding;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 960;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.hairline.withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Table Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.hairline.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
              ),
              child: Row(
                children: columns.map((col) {
                  final child = Align(
                    alignment: col.alignment,
                    child: Text(
                      col.label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.slate,
                      ),
                    ),
                  );
                  if (col.width != null) {
                    return SizedBox(width: col.width, child: child);
                  }
                  return Expanded(flex: col.flex, child: child);
                }).toList(),
              ),
            ),

            // Table Data Rows
            Expanded(
              child: ListView.separated(
                itemCount: itemCount,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.hairline.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final row = rowBuilder(context, index);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: row.onTap,
                      hoverColor: AppColors.inkTeal.withValues(alpha: 0.03),
                      splashColor: AppColors.inkTeal.withValues(alpha: 0.06),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 13),
                        child: Row(
                          children: List.generate(columns.length, (colIdx) {
                            final col = columns[colIdx];
                            final cell = colIdx < row.cells.length
                                ? row.cells[colIdx]
                                : const SizedBox.shrink();
                            final child = Align(
                              alignment: col.alignment,
                              child: cell,
                            );
                            if (col.width != null) {
                              return SizedBox(width: col.width, child: child);
                            }
                            return Expanded(flex: col.flex, child: child);
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
