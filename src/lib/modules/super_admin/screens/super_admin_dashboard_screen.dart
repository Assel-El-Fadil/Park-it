import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/super_admin/routes/super_admin_routes.dart';

class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Super Admin Dashboard',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.textPrimary,
          ),
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.pushNamed(SuperAdminRoutes.profile);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Admins',
                      value: '12',
                      icon: Icons.admin_panel_settings,
                      color: AppColors.primary,
                      onTap: () => context.pushNamed(SuperAdminRoutes.admins),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Active Users',
                      value: '1,248',
                      icon: Icons.people,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Parkings',
                      value: '342',
                      icon: Icons.local_parking,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'Reservations',
                      value: '5,621',
                      icon: Icons.calendar_today,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTextStyles.titleMedium.copyWith(
                  color: context.colorScheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              _ActionCard(
                icon: Icons.add_circle,
                title: 'Add New Admin',
                subtitle: 'Create a new admin account',
                onTap: () => context.pushNamed(SuperAdminRoutes.addAdmin),
              ),
              
              const SizedBox(height: 12),
              
              _ActionCard(
                icon: Icons.manage_accounts,
                title: 'Manage Admins',
                subtitle: 'View and manage all admin accounts',
                onTap: () => context.pushNamed(SuperAdminRoutes.admins),
              ),
              
              const SizedBox(height: 12),
              
              _ActionCard(
                icon: Icons.analytics,
                title: 'View Analytics',
                subtitle: 'Detailed platform analytics',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                value,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: context.colorScheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surfaceColor,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: context.colorScheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.colorScheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
