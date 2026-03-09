import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value?.currentUser;

    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (prev, next) {
      next.whenOrNull(
        data: (state) {
          if (!state.isAuthenticated) {
            context.goNamed(AuthRoutes.login);
          }
        },
      );
    });

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: context.textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: _ProfileContent(
            user: user,
            isLoading: authState.value?.isLoading ?? false,
            errorMessage: authState.value?.errorMessage,
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  const _ProfileContent({
    required this.user,
    required this.isLoading,
    this.errorMessage,
  });

  final UserModel user;
  final bool isLoading;
  final String? errorMessage;

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void didUpdateWidget(covariant _ProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user && !_isEditMode) {
      _firstNameController.text = widget.user.firstName;
      _lastNameController.text = widget.user.lastName;
      _phoneController.text = widget.user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updatedUser = widget.user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );
    await ref.read(authNotifierProvider.notifier).updateProfile(updatedUser);
    setState(() => _isEditMode = false);
  }

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (context.mounted) {
      context.goNamed(AuthRoutes.login);
    }
  }

  void _onPhotoEditTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo upload coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: context.surfaceColor,
                backgroundImage: widget.user.profilePhoto != null &&
                        widget.user.profilePhoto!.isNotEmpty
                    ? NetworkImage(widget.user.profilePhoto!)
                    : null,
                child: widget.user.profilePhoto == null ||
                        widget.user.profilePhoto!.isEmpty
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
                  onTap: _onPhotoEditTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.backgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (widget.errorMessage != null &&
            widget.errorMessage!.isNotEmpty) ...[
          Text(
            widget.errorMessage!,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        if (_isEditMode) ...[
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First name',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last name',
            ),
          ),
        ] else ...[
          Text(
            '${widget.user.firstName} ${widget.user.lastName}'.trim(),
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          initialValue: widget.user.email,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          readOnly: !_isEditMode,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone',
            suffixIcon: _isEditMode ? null : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: Text(
              widget.user.role.name.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(5, (index) {
              final rating = widget.user.averageRating;
              final fillAmount = (rating - index).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  fillAmount >= 1
                      ? Icons.star
                      : fillAmount > 0
                          ? Icons.star_half
                          : Icons.star_border,
                  color: AppColors.accent,
                  size: 24,
                ),
              );
            }),
            const SizedBox(width: 8),
            Text(
              '${widget.user.averageRating.toStringAsFixed(1)} (${widget.user.totalReviews} reviews)',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (_isEditMode)
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _save,
              child: widget.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          )
        else
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _isEditMode = true),
              icon: const Icon(Icons.edit, size: 20),
              label: const Text('Edit profile'),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            onPressed: widget.isLoading ? null : _logout,
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
