import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';

// TODO: REMOVE FOR PRODUCTION — dev-only mock user for frontend testing
const _kDevMockUser = UserModel(
  id: '1',
  firstName: 'Jane',
  lastName: 'Doe',
  email: 'jane.doe@example.com',
  averageRating: 4.8,
  totalReviews: 23,
  role: UserRole.driver,
);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    // TODO: REMOVE FOR PRODUCTION — bypass auth guard for frontend testing
    final user = authState.value?.currentUser ?? _kDevMockUser;

    // ref.listen<AsyncValue<AppAuthState>>(authNotifierProvider, (prev, next) {
    //   next.whenOrNull(
    //     data: (state) {
    //       if (!state.isAuthenticated) {
    //         context.go(AuthRoutes.login);
    //       }
    //     },
    //   );
    // });

    if (false) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading profile...', style: context.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AuthRoutes.login);
            }
          },
        ),
        title: Text(
          'Profile',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: context.backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(user: user),
              const SizedBox(height: 32),
              _SectionHeader(title: 'ACCOUNT'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.person_outline,
                title: 'Personal Information',
                onTap: () {
                  // TODO: Navigate to edit profile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Personal Information coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.directions_car_outlined,
                title: 'My Vehicles',
                onTap: () {
                  context.push(AuthRoutes.vehicles);
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                onTap: () {
                  // TODO: Navigate to payment methods
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment Methods coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.location_on_outlined,
                title: 'Saved Locations',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved Locations coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'PREFERENCES'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  context.push(AppRoutes.settingsPath);
                },
              ),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.palette_outlined,
                title: 'Appearance',
                onTap: () {
                  context.push(AppRoutes.settingsPath);
                },
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'SUPPORT'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.help_outline,
                title: 'Help Center',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help Center coming soon')),
                  );
                },
              ),
              const SizedBox(height: 32),
              _LogoutButton(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _ProfileBottomNav(
        currentIndex: 3,
        onExplore: () => context.go(AppRoutes.landing),
        onBookings: () {},
        onWallet: () => _navigatePlaceholder(context, 'Wallet'),
        onProfile: () {},
      ),
    );
  }

  void _navigatePlaceholder(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label coming soon')));
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
              backgroundImage:
                  user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                  ? NetworkImage(user.profilePhoto!)
                  : null,
              child: user.profilePhoto == null || user.profilePhoto!.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 56,
                      color: context.colorScheme.textTertiary,
                    )
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo upload coming soon')),
                  );
                },
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius * 2,
                ),
              ),
              child: Text(
                'Pro Member',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Since 2022',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
            ),
          ],
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
      elevation: 0,
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

class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.value?.isLoading ?? false;

    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading
            ? null
            : () async {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AuthRoutes.login);
                }
              },
        icon: const Icon(Icons.logout, size: 20),
        label: const Text('Logout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _ProfileBottomNav extends StatelessWidget {
  const _ProfileBottomNav({
    required this.currentIndex,
    required this.onExplore,
    required this.onBookings,
    required this.onWallet,
    required this.onProfile,
  });

  final int currentIndex;
  final VoidCallback onExplore;
  final VoidCallback onBookings;
  final VoidCallback onWallet;
  final VoidCallback onProfile;

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
              onTap: onExplore,
            ),
            _NavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Bookings',
              isSelected: currentIndex == 1,
              onTap: onBookings,
            ),
            _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
              isSelected: currentIndex == 2,
              onTap: onWallet,
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isSelected: currentIndex == 3,
              onTap: onProfile,
            ),
          ],
        ),
      ),
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
