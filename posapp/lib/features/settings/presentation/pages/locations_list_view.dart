import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_modal.dart';
import '../../../../core/widgets/management_grid_table.dart';
import '../../../../core/widgets/management_header.dart';
import '../../../Organisations/data/orgs_repository.dart';
import '../widgets/location_card.dart';
import './add_edit_location_view.dart';

class LocationsListView extends StatefulWidget {
  const LocationsListView({super.key});

  @override
  State<LocationsListView> createState() => _LocationsListViewState();
}

class _LocationsListViewState extends State<LocationsListView> {
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
      title: 'Add Location',
      subtitle: 'Create a new branch or store location',
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
      title: 'Edit Location',
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
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to remove "${loc.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _locations.removeWhere((l) => l.id == loc.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location "${loc.name}" deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
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
          title: 'Locations',
          subtitle: 'Store Branches & Outlets',
          itemCountText:
              '${locations.length} ${locations.length == 1 ? 'location' : 'locations'}',
          actionLabel: 'Add Location',
          actionIcon: Icons.add,
          onActionTap: _openAddLocation,
        ),
        Expanded(
          child: ManagementGridTable<LocationProps>(
            items: locations,
            isLoading: _isLoading,
            emptyTitle: 'No locations yet',
            emptySubtitle:
                'Add your store branches to manage inventory and staff per outlet.',
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
                label: 'Outlet Name',
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
                label: 'Outlet Type',
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
                label: 'Status',
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
                      isActive ? 'Active' : 'Inactive',
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
      label: 'Add Location',
      onTap: _openAddLocation,
    );

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
            Text(
              'Locations',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 17),
            ),
            Text(
              'Manage store branches',
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
