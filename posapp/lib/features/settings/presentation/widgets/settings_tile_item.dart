import 'package:flutter/material.dart';

/// Data model representing a single setting item row within a group.
class SettingsTileItem {
  const SettingsTileItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.badgeText,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final String? badgeText;
}
