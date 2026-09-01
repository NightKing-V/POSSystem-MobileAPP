import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/staff_repository.dart';
import './add_edit_employee_view.dart';

class EmployeesListView extends StatefulWidget {
  const EmployeesListView({super.key, this.orgId});

  final String? orgId;

  @override
  State<EmployeesListView> createState() => _EmployeesListViewState();
}

class _EmployeesListViewState extends State<EmployeesListView> {
  final _staffRepo = StaffRepository();
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  List<StaffUserProps> _employees = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    final response = await _staffRepo.fetchStaffUsers(orgId: widget.orgId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _employees = response.data!;
      }
    });
  }

  List<StaffUserProps> get _filtered {
    if (_search.isEmpty) return _employees;
    final q = _search.toLowerCase();
    return _employees
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.email.toLowerCase().contains(q) ||
            (e.phone != null && e.phone!.contains(q)) ||
            (e.role != null && e.role!.toLowerCase().contains(q)) ||
            (e.locationName != null && e.locationName!.toLowerCase().contains(q)))
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
            Text(context.tr('staff.title'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 17)),
            Text('${employees.length} staff members',
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
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: context.tr('common.search'),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : employees.isEmpty
                          ? const _EmptySearch()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                              itemCount: employees.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, i) => _EmployeeTile(
                                employee: employees[i],
                                onTap: () {},
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
        label: Text(context.tr('staff.add_employee'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.onTap});

  final StaffUserProps employee;
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
                initials.isNotEmpty ? initials : 'S',
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
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.ink)),
                      const Spacer(),
                      _StatusDot(active: employee.isActive),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(employee.role ?? 'Employee',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.inkTeal,
                              fontWeight: FontWeight.w600)),
                      if (employee.locationName != null) ...[
                        const Text(' · ',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.slate)),
                        Text(employee.locationName!,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.slate)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.slate, size: 18),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF0F9D58).withValues(alpha: 0.1)
            : AppColors.slate.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFF0F9D58) : AppColors.slate,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF0F9D58) : AppColors.slate,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_outlined,
                size: 48, color: AppColors.slate.withAlpha(80)),
            const SizedBox(height: 16),
            Text('No staff found',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Try adjusting your search terms.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
