import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';

/// Column definition for [ManagementGridTable].
class ManagementTableColumn<T> {
  const ManagementTableColumn({
    required this.label,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.isSortable = false,
    this.cellBuilder,
  });

  final String label;
  final int flex;
  final double? width;
  final Alignment alignment;
  final bool isSortable;
  final Widget Function(T item, int index)? cellBuilder;
}

/// Unified, highly configurable Grid & Table component for all Management pages.
/// - **Desktop (`>= 960px`)**: Renders an enterprise Data Table with column sorting, cell formatting, inline actions, and pagination.
/// - **Tablet & Mobile (`< 960px`)**: Renders a responsive flex grid of cards with pagination controls.
class ManagementGridTable<T> extends StatefulWidget {
  const ManagementGridTable({
    super.key,
    required this.items,
    required this.columns,
    this.cardBuilder,
    this.rowCellsBuilder,
    // Actions
    this.onTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.actionsColumnWidth = 110,
    // Sorting
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    // Pagination
    this.enablePagination = true,
    this.rowsPerPage = 10,
    this.rowsPerPageOptions = const [10, 20, 50],
    this.currentPage,
    this.totalItems,
    this.onPageChanged,
    this.onRowsPerPageChanged,
    // States
    this.isLoading = false,
    this.emptyTitle = 'No items found',
    this.emptySubtitle,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyWidget,
    // Grid settings for tablet/mobile
    this.gridMaxCrossAxisExtent = 380,
    this.gridMainAxisExtent = 88,
    this.gridCrossAxisSpacing = 12,
    this.gridMainAxisSpacing = 12,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
  });

  final List<T> items;
  final List<ManagementTableColumn<T>> columns;
  final Widget Function(BuildContext context, T item, int index)? cardBuilder;
  final List<Widget> Function(BuildContext context, T item, int index)?
      rowCellsBuilder;

  // Actions
  final void Function(T item)? onTap;
  final void Function(T item)? onView;
  final void Function(T item)? onEdit;
  final void Function(T item)? onDelete;
  final double actionsColumnWidth;

  // Sorting
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;

  // Pagination
  final bool enablePagination;
  final int rowsPerPage;
  final List<int> rowsPerPageOptions;
  final int? currentPage;
  final int? totalItems;
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int?>? onRowsPerPageChanged;

  // States
  final bool isLoading;
  final String emptyTitle;
  final String? emptySubtitle;
  final IconData emptyIcon;
  final Widget? emptyWidget;

  // Grid layout parameters
  final double gridMaxCrossAxisExtent;
  final double gridMainAxisExtent;
  final double gridCrossAxisSpacing;
  final double gridMainAxisSpacing;
  final EdgeInsets padding;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 960;

  @override
  State<ManagementGridTable<T>> createState() => _ManagementGridTableState<T>();
}

class _ManagementGridTableState<T> extends State<ManagementGridTable<T>> {
  int _localPage = 0;
  late int _localRowsPerPage;

  @override
  void initState() {
    super.initState();
    _localRowsPerPage = widget.rowsPerPage;
  }

  @override
  void didUpdateWidget(covariant ManagementGridTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      final maxPage = (widget.items.length / _localRowsPerPage).ceil();
      if (_localPage >= maxPage && maxPage > 0) {
        _localPage = maxPage - 1;
      }
    }
  }

  bool get _hasActions =>
      widget.onView != null ||
      widget.onEdit != null ||
      widget.onDelete != null;

  int get _activePage => widget.currentPage ?? _localPage;
  int get _totalCount => widget.totalItems ?? widget.items.length;

  List<T> get _pagedItems {
    if (!widget.enablePagination || widget.onPageChanged != null) {
      return widget.items;
    }
    final start = _activePage * _localRowsPerPage;
    if (start >= widget.items.length) return [];
    final end = (start + _localRowsPerPage).clamp(0, widget.items.length);
    return widget.items.sublist(start, end);
  }

  void _handlePageChange(int newPage) {
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(newPage);
    } else {
      setState(() => _localPage = newPage);
    }
  }

  void _handleRowsPerPageChange(int? newRows) {
    if (newRows == null) return;
    if (widget.onRowsPerPageChanged != null) {
      widget.onRowsPerPageChanged!(newRows);
    } else {
      setState(() {
        _localRowsPerPage = newRows;
        _localPage = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (widget.items.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.emptyIcon,
                    size: 48,
                    color: AppColors.slate.withValues(alpha: 0.45),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.emptyTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (widget.emptySubtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.emptySubtitle!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.slate,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          );
    }

    final isDesktop = ManagementGridTable.isDesktop(context);

    return isDesktop ? _buildDesktopTable(context) : _buildMobileGrid(context);
  }

  Widget _buildDesktopTable(BuildContext context) {
    final displayList = _pagedItems;

    return Padding(
      padding: widget.padding,
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
                children: [
                  ...List.generate(widget.columns.length, (colIdx) {
                    final col = widget.columns[colIdx];
                    final isCurrentSort = widget.sortColumnIndex == colIdx;

                    Widget headerLabel = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            col.label.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: isCurrentSort
                                  ? AppColors.inkTeal
                                  : AppColors.slate,
                            ),
                          ),
                        ),
                        if (col.isSortable) ...[
                          const SizedBox(width: 4),
                          Icon(
                            isCurrentSort
                                ? (widget.sortAscending
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded)
                                : Icons.unfold_more_rounded,
                            size: 14,
                            color: isCurrentSort
                                ? AppColors.inkTeal
                                : AppColors.slate.withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    );

                    if (col.isSortable && widget.onSort != null) {
                      headerLabel = InkWell(
                        onTap: () {
                          final ascending =
                              isCurrentSort ? !widget.sortAscending : true;
                          widget.onSort!(colIdx, ascending);
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          child: headerLabel,
                        ),
                      );
                    }

                    final headerContainer = Align(
                      alignment: col.alignment,
                      child: headerLabel,
                    );

                    if (col.width != null) {
                      return SizedBox(width: col.width, child: headerContainer);
                    }
                    return Expanded(flex: col.flex, child: headerContainer);
                  }),
                  if (_hasActions)
                    SizedBox(
                      width: widget.actionsColumnWidth,
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'ACTIONS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.slate,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Table Body Rows
            Expanded(
              child: ListView.separated(
                itemCount: displayList.length,
                separatorBuilder: (ctx, i) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.hairline.withValues(alpha: 0.5),
                ),
                itemBuilder: (context, index) {
                  final item = displayList[index];
                  final originalIndex = widget.enablePagination
                      ? (_activePage * _localRowsPerPage) + index
                      : index;

                  final cells = widget.rowCellsBuilder != null
                      ? widget.rowCellsBuilder!(context, item, originalIndex)
                      : widget.columns.map((col) {
                          if (col.cellBuilder != null) {
                            return col.cellBuilder!(item, originalIndex);
                          }
                          return const Text('—');
                        }).toList();

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (widget.onTap != null) {
                          widget.onTap!(item);
                        } else if (widget.onEdit != null) {
                          widget.onEdit!(item);
                        } else if (widget.onView != null) {
                          widget.onView!(item);
                        }
                      },
                      hoverColor: AppColors.inkTeal.withValues(alpha: 0.03),
                      splashColor: AppColors.inkTeal.withValues(alpha: 0.06),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        child: Row(
                          children: [
                            ...List.generate(widget.columns.length, (colIdx) {
                              final col = widget.columns[colIdx];
                              final cellWidget = colIdx < cells.length
                                  ? cells[colIdx]
                                  : const SizedBox.shrink();

                              final alignedCell = Align(
                                alignment: col.alignment,
                                child: cellWidget,
                              );

                              if (col.width != null) {
                                return SizedBox(
                                    width: col.width, child: alignedCell);
                              }
                              return Expanded(
                                  flex: col.flex, child: alignedCell);
                            }),
                            if (_hasActions)
                              SizedBox(
                                width: widget.actionsColumnWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.onView != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 17,
                                          color: AppColors.inkTeal,
                                        ),
                                        tooltip: context.tr('common.view_details'),
                                        splashRadius: 18,
                                        onPressed: () => widget.onView!(item),
                                      ),
                                    if (widget.onEdit != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 17,
                                          color: AppColors.slate,
                                        ),
                                        tooltip: context.tr('common.edit'),
                                        splashRadius: 18,
                                        onPressed: () => widget.onEdit!(item),
                                      ),
                                    if (widget.onDelete != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 17,
                                          color: AppColors.error,
                                        ),
                                        tooltip: context.tr('common.delete'),
                                        splashRadius: 18,
                                        onPressed: () => widget.onDelete!(item),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Pagination Controls Bar
            if (widget.enablePagination) _buildPaginationBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileGrid(BuildContext context) {
    final displayList = _pagedItems;

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 80),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: widget.gridMaxCrossAxisExtent,
              mainAxisExtent: widget.gridMainAxisExtent,
              crossAxisSpacing: widget.gridCrossAxisSpacing,
              mainAxisSpacing: widget.gridMainAxisSpacing,
            ),
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final item = displayList[index];
              final originalIndex = widget.enablePagination
                  ? (_activePage * _localRowsPerPage) + index
                  : index;

              if (widget.cardBuilder != null) {
                return widget.cardBuilder!(context, item, originalIndex);
              }

              // Fallback Default Card
              return Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.hairline.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    if (widget.onTap != null) {
                      widget.onTap!(item);
                    } else if (widget.onEdit != null) {
                      widget.onEdit!(item);
                    } else if (widget.onView != null) {
                      widget.onView!(item);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        if (_hasActions) ...[
                          if (widget.onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.slate),
                              onPressed: () => widget.onEdit!(item),
                            ),
                          if (widget.onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.error),
                              onPressed: () => widget.onDelete!(item),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.enablePagination && _totalCount > _localRowsPerPage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _buildPaginationBar(context, isCompact: true),
          ),
      ],
    );
  }

  Widget _buildPaginationBar(BuildContext context, {bool isCompact = false}) {
    final rowsPerPage = _localRowsPerPage;
    final total = _totalCount;
    final maxPage = (total / rowsPerPage).ceil();
    final startItem = total == 0 ? 0 : (_activePage * rowsPerPage) + 1;
    final endItem = ((_activePage + 1) * rowsPerPage).clamp(0, total);

    final canGoPrev = _activePage > 0;
    final canGoNext = _activePage < (maxPage - 1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 18,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: isCompact ? BorderRadius.circular(10) : null,
        border: Border(
          top: isCompact
              ? BorderSide.none
              : BorderSide(
                  color: AppColors.hairline.withValues(alpha: 0.8),
                  width: 1.2,
                ),
        ),
      ),
      child: Row(
        children: [
          if (!isCompact) ...[
            Text(
              context.tr('common.rows_per_page'),
              style: const TextStyle(fontSize: 12, color: AppColors.slate),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.hairline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: widget.rowsPerPageOptions.contains(rowsPerPage)
                      ? rowsPerPage
                      : widget.rowsPerPageOptions.first,
                  isDense: true,
                  iconSize: 16,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink),
                  items: widget.rowsPerPageOptions
                      .map((val) => DropdownMenuItem<int>(
                            value: val,
                            child: Text('$val'),
                          ))
                      .toList(),
                  onChanged: _handleRowsPerPageChange,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Text(
            context.tr('common.showing_range', args: {
              'start': '$startItem',
              'end': '$endItem',
              'total': '$total',
            }),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.slate,
            ),
          ),
          const Spacer(),
          Text(
            context.tr('common.page_of', args: {
              'page': '${_activePage + 1}',
              'total': '${maxPage == 0 ? 1 : maxPage}',
            }),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            splashRadius: 18,
            color: canGoPrev ? AppColors.ink : AppColors.slate.withAlpha(80),
            onPressed: canGoPrev ? () => _handlePageChange(_activePage - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            splashRadius: 18,
            color: canGoNext ? AppColors.ink : AppColors.slate.withAlpha(80),
            onPressed: canGoNext ? () => _handlePageChange(_activePage + 1) : null,
          ),
        ],
      ),
    );
  }
}
