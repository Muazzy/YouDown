import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:you_down/utils/app_colors.dart';

class CustomBadge extends StatelessWidget {
  const CustomBadge({
    super.key,
    required this.child,
    required this.showBadge,
    required this.badgeContent,
  });

  final Widget child;
  final bool showBadge;
  final String badgeContent;

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      badgeContent: Text(
        badgeContent,
        style: const TextStyle(color: Colors.white),
      ),
      badgeStyle: const badges.BadgeStyle(
        badgeColor: AppColors.primary,
        shape: badges.BadgeShape.circle,
      ),
      position: badges.BadgePosition.topEnd(top: -4, end: 2),
      showBadge: showBadge,
      child: child,
    );
  }
}
