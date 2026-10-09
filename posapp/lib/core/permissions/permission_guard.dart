import 'package:flutter/material.dart';
import './permissions_service.dart';

/// PermissionGuard conditionally displays [child] if the current user possesses [permission].
/// If permission is denied, it renders [fallback] (defaults to `const SizedBox.shrink()`).
class PermissionGuard extends StatelessWidget {
  const PermissionGuard({
    super.key,
    this.permission,
    this.anyPermissions,
    this.allPermissions,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final String? permission;
  final List<String>? anyPermissions;
  final List<String>? allPermissions;
  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PermissionsService(),
      builder: (context, _) {
        final service = PermissionsService();
        bool allowed = true;

        if (permission != null) {
          allowed = service.hasPermission(permission!);
        } else if (anyPermissions != null) {
          allowed = service.hasAnyPermission(anyPermissions!);
        } else if (allPermissions != null) {
          allowed = service.hasAllPermissions(allPermissions!);
        }

        return allowed ? child : fallback;
      },
    );
  }
}
