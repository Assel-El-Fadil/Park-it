import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/super_admin/routes/super_admin_routes.dart';

class SuperAdminProfileScreen extends ConsumerWidget {
  const SuperAdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value?.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Super Admin Profile',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.textPrimary,
          ),
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              _ProfileHeader(user: user),
              const SizedBox(height: 32),
              
              // Account Section
              _SectionHeader(title: 'ACCOUNT'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile coming soon')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.security,
                title: 'Security Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Security settings coming soon')),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Admin Management Section
              _SectionHeader(title: 'ADMIN MANAGEMENT'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.admin_panel_settings,
                title: 'Manage Admins',
                onTap: () {
                  context.pushNamed(SuperAdminRoutes.admins);
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.add_circle,
                title: 'Add New Admin',
                onTap: () {
                  context.pushNamed(SuperAdminRoutes.addAdmin);
                },
              ),
              
              const SizedBox(height: 24),
              
              // System Section
              _SectionHeader(title: 'SYSTEM'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.analytics,
                title: 'System Analytics',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics coming soon')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.settings,
                title: 'System Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('System settings coming soon')),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Support Section
              _SectionHeader(title: 'SUPPORT'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help center coming soon')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.contact_support,
                title: 'Contact Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact support coming soon')),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Logout Button
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
              
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: context.surfaceColor,
              child: Icon(
                Icons.admin_panel_settings,
                size: 56,
                color: context.colorScheme.textTertiary,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.backgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${user.firstName} ${user.lastName}'.trim(),
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          user.email ?? 'No email',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius * 2,
            ),
          ),
          child: Text(
            'Super Admin',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMedium.copyWith(
        color: context.colorScheme.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.largePadding,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: context.colorScheme.textPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: context.colorScheme.textPrimary,
                  ),
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
