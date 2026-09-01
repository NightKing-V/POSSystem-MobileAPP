import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/domain/mock_data.dart';
import './add_edit_employee_view.dart';

class EmployeesListView extends StatefulWidget {
  const EmployeesListView({super.key});

  @override
  State<EmployeesListView> createState() => _EmployeesListViewState();
}

class _EmployeesListViewState extends State<EmployeesListView> {
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  List<MockEmployee> get _filtered {
    if (_search.isEmpty) return mockEmployees;
    final q = _search.toLowerCase();
    return mockEmployees
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.contact.toLowerCase().contains(q) ||
            locationName(e.locationId).toLowerCase().contains(q) ||
            permissionSetName(e.permissionSetId).toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = _filtered;

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
            Text('Employees',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text('${mockEmployees.length} staff members',
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
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name, role or location…',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.slate, size: 20),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  size: 18, color: AppColors.slate),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: employees.isEmpty
                      ? const _EmptySearch()
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: employees.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) => _EmployeeTile(
                            employee: employees[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(fullscreenDialog: true, 
                                builder: (_) => AddEditEmployeeView(
                                    employee: employees[i]),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(fullscreenDialog: true, builder: (_) => const AddEditEmployeeView()),
        ),
        backgroundColor: AppColors.inkTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Employee',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.onTap});

  final MockEmployee employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = employee.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .take(2)
        .join();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.hairline.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.inkTeal.withValues(alpha: 0.1),
              child: Text(
                initials,
                style: const TextStyle(
                    color: AppColors.inkTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(employee.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      _RoleBadge(
                          label: permissionSetName(employee.permissionSetId)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${locationName(employee.locationId)}  ·  ${employee.contact}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusDot(isActive: employee.isActive),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.marigold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.inkTeal)),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF16A34A) : AppColors.slate,
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 40, color: AppColors.slate.withValues(alpha: 0.4)),
          const SizedBox(height: 10),
          Text('No employees found',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

