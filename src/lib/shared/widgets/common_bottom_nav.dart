import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';

class CommonBottomNav extends StatelessWidget {
  const CommonBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.search,
              label: 'Explore',
              isSelected: currentIndex == 0,
              onTap: () => context.go(AppRoutes.landing),
            ),
            _NavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Bookings',
              isSelected: currentIndex == 1,
              onTap: () => context.go('/reservations'),
            ),
            _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              isSelected: currentIndex == 2,
              onTap: () => _placeholder(context, 'Wallet'),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isSelected: currentIndex == 3,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }

  void _placeholder(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name coming soon')),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.secondary
        : context.colorScheme.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
