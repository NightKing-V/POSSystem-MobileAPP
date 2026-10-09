import 'package:flutter/material.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../../Organisations/data/orgs_repository.dart';
import '../widgets/location_card.dart';
import './add_edit_location_view.dart';

import '../../../inventory/data/inventory_repository.dart';

class LocationsListView extends StatefulWidget {
  const LocationsListView({
    super.key,
    this.isEmbedded = false,
    this.onBack,
  });

  final bool isEmbedded;
  final VoidCallback? onBack;

  @override
  State<LocationsListView> createState() => _LocationsListViewState();
}

class _LocationsListViewState extends State<LocationsListView> {
  final _inventoryRepo = InventoryRepository();
  final _orgsRepo = OrgsRepository();
  List<LocationProps> _locations = [];
  List<bool> _activeStates = [];
  bool _isLoading = false;

  int? _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    final invRes = await _inventoryRepo.fetchLocations();
    if (!mounted) return;

    if (invRes.isSuccess && invRes.data != null && invRes.data!.isNotEmpty) {
      setState(() {
        _isLoading = false;
        _locations = invRes.data!
            .map((l) => LocationProps(
                  id: l.id,
                  name: l.name,
                  type: l.type,
                  address: l.address,
                  phone: l.phone,
                ))
            .toList();
        _activeStates = _locations.map((_) => true).toList();
      });
      return;
    }

    final res = await _orgsRepo.fetchOrganizations();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (res.isSuccess && res.data != null) {
        final List<LocationProps> locs = [];
        for (final org in res.data!) {
          if (org.locations.isNotEmpty) {
            locs.addAll(org.locations);
          } else {
            locs.add(LocationProps(
              id: org.id,
              name: org.name,
              type: org.category ?? 'BRANCH',
            ));
          }
        }
        _locations = locs;
        _activeStates = _locations.map((_) => true).toList();
      }
    });
  }

  List<LocationProps> get _processedLocations {
    var list = _locations;
    if (_sortColumnIndex != null) {
      list = List.of(list);
      list.sort((a, b) {
        int comp = 0;
        switch (_sortColumnIndex) {
          case 0:
            comp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
            break;
          case 1:
            comp = a.type.toLowerCase().compareTo(b.type.toLowerCase());
            break;
        }
        return _sortAscending ? comp : -comp;
      });
    }
    return list;
  }

  void _openAddLocation() async {
    final res = await showResponsiveModal<bool>(
      context: context,
      title: context.tr('locations.add_location'),
      subtitle: context.tr('locations.no_locations_hint'),
      leadingIcon: const Icon(Icons.storefront_outlined,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 600,
      builder: (_) => const AddEditLocationView(isModal: true),
    );
    if (res == true) _loadLocations();
  }

  void _openEditLocation(LocationProps loc) async {
    final res = await showResponsiveModal<bool>(
      context: context,
      title: context.tr('locations.edit_location'),
      subtitle: loc.name,
      leadingIcon: const Icon(Icons.storefront_outlined,
          color: AppColors.inkTeal, size: 20),
      maxWidth: 600,
      builder: (_) => AddEditLocationView(location: loc, isModal: true),
    );
    if (res == true) _loadLocations();
  }

  void _handleDelete(LocationProps loc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('locations.delete_location_confirm')),
        content: Text(context.tr('common.confirm_delete_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr('common.cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr('common.delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final deleteRes = await _inventoryRepo.deleteLocation(loc.id);
      if (!mounted) return;

      if (deleteRes.isSuccess) {
        setState(() {
          _locations.removeWhere((l) => l.id == loc.id);
        });
        ApiHelper.showSuccessSnackBar(context, context.tr('common.deleted_success'));
      } else {
        ApiHelper.showErrorSnackBar(
          context,
          deleteRes.errorMessage ?? context.tr('common.error'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locations = _processedLocations;

    final body = Column(
      children: [
        ManagementHeaderBar(
          title: context.tr('locations.title'),
          subtitle: context.tr('settings.locations'),
          itemCountText: context.tr('orgs.locations_count', args: {'count': locations.length}),
          leading: (widget.onBack != null || Navigator.of(context).canPop())
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
                  tooltip: context.tr('common.back'),
                  onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                )
              : null,
          hideMobileTitle: false,
          actionLabel: context.tr('locations.add_location'),
          actionIcon: Icons.add,
          onActionTap: _openAddLocation,
        ),
        Expanded(
          child: ManagementGridTable<LocationProps>(
            items: locations,
            isLoading: _isLoading,
            emptyTitle: context.tr('locations.no_locations'),
            emptySubtitle: context.tr('locations.no_locations_hint'),
            emptyIcon: Icons.storefront_outlined,
            enablePagination: true,
            rowsPerPage: 10,
            gridMaxCrossAxisExtent: 440,
            gridMainAxisExtent: 140,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            onSort: (colIdx, asc) {
              setState(() {
                _sortColumnIndex = colIdx;
                _sortAscending = asc;
              });
            },
            onEdit: (loc) => _openEditLocation(loc),
            onDelete: (loc) => _handleDelete(loc),
            columns: [
              ManagementTableColumn<LocationProps>(
                label: context.tr('locations.branch_name'),
                flex: 3,
                isSortable: true,
                cellBuilder: (loc, _) => Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.inkTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.inkTeal,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      loc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ManagementTableColumn<LocationProps>(
                label: context.tr('common.description'),
                flex: 2,
                isSortable: true,
                cellBuilder: (loc, _) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Text(
                      loc.type,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate,
                      ),
                    ),
                  ),
                ),
              ),
              ManagementTableColumn<LocationProps>(
                label: context.tr('common.status'),
                width: 110,
                cellBuilder: (loc, i) {
                  final isActive =
                      _activeStates.length > i ? _activeStates[i] : true;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF0F9D58).withValues(alpha: 0.1)
                          : AppColors.slate.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? context.tr('common.active') : context.tr('common.inactive'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? const Color(0xFF0F9D58)
                            : AppColors.slate,
                      ),
                    ),
                  );
                },
              ),
            ],
            cardBuilder: (context, loc, i) => LocationCard(
              location: loc,
              isActive: _activeStates.length > i ? _activeStates[i] : true,
              onToggle: (val) {
                if (_activeStates.length > i) {
                  setState(() => _activeStates[i] = val);
                }
              },
              onTap: () => _openEditLocation(loc),
            ),
          ),
        ),
      ],
    );

    final fab = ManagementHeaderBar.buildFab(
      context,
      label: context.tr('locations.add_location'),
      onTap: _openAddLocation,
    );

    if (widget.isEmbedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(top: false, child: body),
        floatingActionButton: fab,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('locations.title'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 17),
            ),
            Text(
              context.tr('locations.location_details'),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(child: body),
      floatingActionButton: fab,
    );
  }
}
