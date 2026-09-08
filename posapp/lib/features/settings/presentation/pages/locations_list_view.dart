import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/domain/mock_data.dart';
import '../widgets/location_card.dart';
import './add_edit_location_view.dart';

class LocationsListView extends StatefulWidget {
  const LocationsListView({super.key});

  @override
  State<LocationsListView> createState() => _LocationsListViewState();
}

class _LocationsListViewState extends State<LocationsListView> {
  late final List<MockLocation> _locations;
  late final List<bool> _activeStates;

  @override
  void initState() {
    super.initState();
    _locations = List.of(mockLocations);
    _activeStates = _locations.map((l) => l.isActive).toList();
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
            Text(
              'Locations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
            ),
            Text(
              'Manage store branches',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              itemCount: _locations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => LocationCard(
                location: _locations[i],
                isActive: _activeStates[i],
                onToggle: (val) => setState(() => _activeStates[i] = val),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => AddEditLocationView(location: _locations[i]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const AddEditLocationView(),
          ),
        ),
        backgroundColor: AppColors.inkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
