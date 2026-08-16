import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/mock_data.dart';
import 'add_edit_location_view.dart';

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
            Text('Locations',
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17)),
            Text('Manage store branches',
                style:
                    Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
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
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _LocationCard(
                location: _locations[i],
                isActive: _activeStates[i],
                onToggle: (val) => setState(() => _activeStates[i] = val),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
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
          MaterialPageRoute(builder: (_) => const AddEditLocationView()),
        ),
        backgroundColor: AppColors.inkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Location',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.isActive,
    required this.onToggle,
    required this.onTap,
  });

  final MockLocation location;
  final bool isActive;
  final ValueChanged<bool> onToggle;
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
          border:
              Border.all(color: AppColors.hairline.withOpacity(0.6), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.inkTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront_outlined,
                      color: AppColors.inkTeal, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(location.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(location.address,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate)),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: onToggle,
                  activeColor: AppColors.inkTeal,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.people_outline,
                  label: '${location.employeeCount} employees',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.percent_outlined,
                  label: '${location.taxRate.toStringAsFixed(0)}% tax',
                ),
                const SizedBox(width: 8),
                _StatusChip(isActive: isActive),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inkTeal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.inkTeal),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkTeal)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF16A34A).withOpacity(0.08)
            : AppColors.slate.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFF16A34A) : AppColors.slate,
        ),
      ),
    );
  }
}
