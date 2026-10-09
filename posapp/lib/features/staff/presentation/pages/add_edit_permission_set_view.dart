import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_helper.dart';
import '../../../../core/api/token_storage.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../data/staff_repository.dart';
import '../validators/staff_validators.dart';

class AddEditPermissionSetView extends StatefulWidget {
  const AddEditPermissionSetView({
    super.key,
    this.role,
    this.orgId,
    this.isModal = true,
  });

  final OrgRoleProps? role;
  final String? orgId;
  final bool isModal;

  @override
  State<AddEditPermissionSetView> createState() =>
      _AddEditPermissionSetViewState();
}

class _AddEditPermissionSetViewState extends State<AddEditPermissionSetView> {
  final _staffRepo = StaffRepository();
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();
  final _permSearchCtrl = TextEditingController();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  bool _isLocationScoped = false;
  bool _isSaving = false;

  // Permissions pagination & dynamic loading state
  List<PermissionItem> _availablePermissions = [];
  final Set<String> _selectedPermissionIds = {};
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _hasMore = true;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  String? _selectedResourceFilter;
  Timer? _debounceTimer;

  bool get _isEditing => widget.role != null;

  String? get _effectiveOrgId => widget.orgId ?? TokenStorage.currentOrgId;

  bool get _allVisibleEnabled =>
      _availablePermissions.isNotEmpty &&
      _availablePermissions.every((p) => _selectedPermissionIds.contains(p.id));

  @override
  void initState() {
    super.initState();
    final r = widget.role;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _isLocationScoped = r?.isLocationScoped ?? false;

    if (r != null) {
      _selectedPermissionIds.addAll(r.permissionIds);
    }

    _scrollCtrl.addListener(_onScroll);
    _loadInitialPermissions();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _permSearchCtrl.dispose();
    _debounceTimer?.cancel();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && !_isLoadingInitial && _hasMore) {
        _loadMorePermissions();
      }
    }
  }

  Future<void> _loadInitialPermissions() async {
    setState(() {
      _isLoadingInitial = true;
      _currentPage = 1;
      _hasMore = true;
    });

    final res = await _staffRepo.fetchPermissions(
      page: 1,
      limit: _pageSize,
      search: _searchQuery,
      resource: _selectedResourceFilter,
    );

    if (!mounted) return;

    setState(() {
      _isLoadingInitial = false;
      if (res.isSuccess && res.data != null && res.data!.items.isNotEmpty) {
        _availablePermissions = res.data!.items;
        _hasMore = res.data!.page < res.data!.totalPages;
      } else {
        // Fallback default permissions list if backend is empty or unavailable
        final defaults = _generateDefaultPermissions();
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          _availablePermissions = defaults
              .where(
                (p) =>
                    p.label.toLowerCase().contains(q) ||
                    p.resource.toLowerCase().contains(q) ||
                    p.action.toLowerCase().contains(q),
              )
              .toList();
        } else if (_selectedResourceFilter != null) {
          _availablePermissions = defaults
              .where(
                (p) =>
                    p.resource.toLowerCase() ==
                    _selectedResourceFilter!.toLowerCase(),
              )
              .toList();
        } else {
          _availablePermissions = defaults;
        }
        _hasMore = false;
      }

      // If editing with legacy names, map to IDs if needed
      if (widget.role != null) {
        for (final p in _availablePermissions) {
          if (widget.role!.permissions.contains(p.resource) ||
              widget.role!.permissions.contains(p.label)) {
            _selectedPermissionIds.add(p.id);
          }
        }
      }
    });
  }

  Future<void> _loadMorePermissions() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final res = await _staffRepo.fetchPermissions(
      page: nextPage,
      limit: _pageSize,
      search: _searchQuery,
      resource: _selectedResourceFilter,
    );

    if (!mounted) return;

    setState(() {
      _isLoadingMore = false;
      if (res.isSuccess && res.data != null && res.data!.items.isNotEmpty) {
        _currentPage = nextPage;
        final existingIds = _availablePermissions.map((p) => p.id).toSet();
        for (final item in res.data!.items) {
          if (!existingIds.contains(item.id)) {
            _availablePermissions.add(item);
          }
        }
        _hasMore = res.data!.page < res.data!.totalPages;
      } else {
        _hasMore = false;
      }
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query.trim();
      });
      _loadInitialPermissions();
    });
  }

  void _onResourceFilterSelected(String? resource) {
    setState(() {
      if (_selectedResourceFilter == resource) {
        _selectedResourceFilter = null;
      } else {
        _selectedResourceFilter = resource;
      }
    });
    _loadInitialPermissions();
  }

  List<PermissionItem> _generateDefaultPermissions() {
    const modules = [
      {
        'resource': 'products',
        'action': 'manage',
        'desc': 'Manage Catalog & Products',
      },
      {
        'resource': 'products',
        'action': 'create',
        'desc': 'Create New Products',
      },
      {
        'resource': 'products',
        'action': 'update',
        'desc': 'Update Product Details & Prices',
      },
      {
        'resource': 'products',
        'action': 'delete',
        'desc': 'Delete Products & Archive',
      },
      {
        'resource': 'bills',
        'action': 'manage',
        'desc': 'POS Checkout, Bills & Receipts',
      },
      {
        'resource': 'bills',
        'action': 'create',
        'desc': 'Process POS Sales & Cashout',
      },
      {
        'resource': 'bills',
        'action': 'void',
        'desc': 'Void Bills & Order Cancellations',
      },
      {
        'resource': 'discounts',
        'action': 'apply',
        'desc': 'Apply Discounts & Coupons',
      },
      {
        'resource': 'discounts',
        'action': 'manage',
        'desc': 'Create & Modify Store Promotions',
      },
      {
        'resource': 'inventory',
        'action': 'manage',
        'desc': 'Inventory Stock & Locations',
      },
      {
        'resource': 'inventory',
        'action': 'adjust',
        'desc': 'Stock In/Out & Adjustments',
      },
      {
        'resource': 'suppliers',
        'action': 'manage',
        'desc': 'Suppliers & Purchase Orders',
      },
      {
        'resource': 'suppliers',
        'action': 'create',
        'desc': 'Issue Purchase Orders',
      },
      {
        'resource': 'customers',
        'action': 'manage',
        'desc': 'Customers & Loyalty Points',
      },
      {
        'resource': 'roles',
        'action': 'manage',
        'desc': 'Staff Accounts & Roles',
      },
      {
        'resource': 'settings',
        'action': 'manage',
        'desc': 'General & Business Settings',
      },
    ];

    return modules
        .map(
          (m) => PermissionItem(
            id: '${m['resource']}_${m['action']}',
            resource: m['resource']!,
            action: m['action']!,
            description: m['desc']!,
          ),
        )
        .toList();
  }

  void _toggleAllVisible(bool value) {
    setState(() {
      if (value) {
        _selectedPermissionIds.addAll(_availablePermissions.map((p) => p.id));
      } else {
        for (final p in _availablePermissions) {
          _selectedPermissionIds.remove(p.id);
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final orgId = _effectiveOrgId;
    if (!_isEditing && (orgId == null || orgId.isEmpty)) {
      ApiHelper.showErrorSnackBar(
        context,
        'Organization ID is missing. Please select a business first.',
      );
      return;
    }

    setState(() => _isSaving = true);

    final selectedIds = _selectedPermissionIds.toList();

    ApiResponse<Map<String, dynamic>> res;

    if (_isEditing) {
      final dto = UpdateRoleDto(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : null,
        isLocationScoped: _isLocationScoped,
        permissionIds: selectedIds,
      );
      res = await _staffRepo.updateOrgRole(widget.role!.id, dto);
    } else {
      final dto = CreateRoleDto(
        orgId: orgId!,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : null,
        isLocationScoped: _isLocationScoped,
        permissionIds: selectedIds,
      );
      res = await _staffRepo.createOrgRole(dto);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.isSuccess) {
      ApiHelper.showSuccessSnackBar(
        context,
        _isEditing
            ? context.tr('common.updated_success')
            : context.tr('common.created_success'),
      );
      Navigator.of(context).pop(true);
    } else {
      ApiHelper.showErrorSnackBar(
        context,
        res.errorMessage ?? context.tr('common.error'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resourceCategories = [
      {'label': context.tr('staff.cat_products'), 'value': 'products'},
      {'label': context.tr('staff.cat_bills'), 'value': 'bills'},
      {'label': context.tr('staff.cat_inventory'), 'value': 'inventory'},
      {'label': context.tr('staff.cat_discounts'), 'value': 'discounts'},
      {'label': context.tr('staff.cat_suppliers'), 'value': 'suppliers'},
      {'label': context.tr('staff.cat_customers'), 'value': 'customers'},
      {'label': context.tr('staff.cat_roles'), 'value': 'roles'},
      {'label': context.tr('staff.cat_settings'), 'value': 'settings'},
    ];

    final formFields = SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('staff.role_details'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 14),
            AppTextFormField(
              label: context.tr('staff.role_name'),
              isRequired: true,
              controller: _nameCtrl,
              hintText: context.tr('staff.role_name_hint'),
              validator: StaffValidators.roleName.validate,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: context.tr('common.description'),
              isRequired: false,
              controller: _descCtrl,
              hintText: context.tr('staff.description_hint'),
              validator: StaffValidators.roleDescription.validate,
            ),
            const SizedBox(height: 16),

            // Location Scoped toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isLocationScoped,
              onChanged: (v) => setState(() => _isLocationScoped = v),
              activeThumbColor: AppColors.inkTeal,
              title: Text(
                context.tr('staff.location_scoped'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                context.tr('staff.location_scoped_desc'),
                style: const TextStyle(fontSize: 12, color: AppColors.slate),
              ),
              secondary: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.marigold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.inkTeal,
                  size: 20,
                ),
              ),
            ),

            const Divider(color: AppColors.hairline, height: 28),

            // Header for Permissions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('staff.access_permissions'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr(
                        'staff.permissions_assigned',
                        args: {'count': _selectedPermissionIds.length},
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inkTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.tr(
                      'staff.selected_count',
                      args: {'count': _selectedPermissionIds.length},
                    ),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inkTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Permissions Search Bar
            TextField(
              controller: _permSearchCtrl,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13, color: AppColors.ink),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                hintText: context.tr('staff.search_permissions'),
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.slate,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.slate,
                  size: 18,
                ),
                suffixIcon: _permSearchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 16,
                          color: AppColors.slate,
                        ),
                        onPressed: () {
                          _permSearchCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: resourceCategories.map((cat) {
                  final isSelected = _selectedResourceFilter == cat['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? AppColors.inkTeal : AppColors.ink,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.inkTeal.withValues(alpha: 0.12),
                      checkmarkColor: AppColors.inkTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.inkTeal
                              : AppColors.hairline,
                        ),
                      ),
                      onSelected: (_) =>
                          _onResourceFilterSelected(cat['value']),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Master switch for visible items
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _allVisibleEnabled,
              onChanged: _availablePermissions.isEmpty
                  ? null
                  : _toggleAllVisible,
              activeThumbColor: AppColors.inkTeal,
              title: Text(
                context.tr('staff.select_all_visible'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Text(
                context.tr(
                  'staff.toggle_visible_desc',
                  args: {'count': _availablePermissions.length},
                ),
                style: const TextStyle(fontSize: 11.5, color: AppColors.slate),
              ),
              secondary: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.inkTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.inkTeal,
                  size: 20,
                ),
              ),
            ),
            const Divider(color: AppColors.hairline, height: 1),

            if (_isLoadingInitial)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.inkTeal,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (_availablePermissions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 36,
                        color: AppColors.slate.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('staff.no_permissions_found'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Permission items list
              for (int i = 0; i < _availablePermissions.length; i++) ...[
                _PermissionItemTile(
                  permission: _availablePermissions[i],
                  isSelected: _selectedPermissionIds.contains(
                    _availablePermissions[i].id,
                  ),
                  onChanged: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPermissionIds.add(_availablePermissions[i].id);
                      } else {
                        _selectedPermissionIds.remove(
                          _availablePermissions[i].id,
                        );
                      }
                    });
                  },
                ),
                if (i != _availablePermissions.length - 1)
                  const Divider(color: AppColors.hairline, height: 1),
              ],

              // On-scroll loading spinner
              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.inkTeal,
                      ),
                    ),
                  ),
                ),

              if (!_hasMore && _availablePermissions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 8),
                  child: Center(
                    child: Text(
                      '${_availablePermissions.length} / ${_availablePermissions.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.slate,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    final actionButtons = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.hairline.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate,
                side: const BorderSide(color: AppColors.hairline, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 48),
              ),
              child: Text(context.tr('common.cancel')),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inkTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 48),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isEditing
                          ? context.tr('common.save')
                          : context.tr('staff.add_role'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: formFields),
        actionButtons,
      ],
    );

    if (widget.isModal) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          _isEditing
              ? context.tr('staff.edit_role')
              : context.tr('staff.add_role'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 17),
        ),
      ),
      body: SafeArea(child: content),
    );
  }
}

class _PermissionItemTile extends StatelessWidget {
  const _PermissionItemTile({
    required this.permission,
    required this.isSelected,
    required this.onChanged,
  });

  final PermissionItem permission;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  static const _resourceIcons = <String, IconData>{
    'products': Icons.inventory_2_outlined,
    'bills': Icons.point_of_sale_outlined,
    'discounts': Icons.local_offer_outlined,
    'inventory': Icons.warehouse_outlined,
    'suppliers': Icons.local_shipping_outlined,
    'customers': Icons.people_outline,
    'roles': Icons.admin_panel_settings_outlined,
    'settings': Icons.settings_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final icon =
        _resourceIcons[permission.resource.toLowerCase()] ?? Icons.lock_outline;

    return SwitchListTile(
      value: isSelected,
      onChanged: onChanged,
      activeThumbColor: AppColors.inkTeal,
      title: Text(
        permission.label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.inkTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                permission.resource.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.inkTeal,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              permission.action.toUpperCase(),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.slate,
              ),
            ),
          ],
        ),
      ),
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.inkTeal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.inkTeal, size: 19),
      ),
    );
  }
}
