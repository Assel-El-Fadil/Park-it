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
import 'package:src/modules/auth/widgets/social_login_buttons.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AsyncValue<AppAuthState>>(authNotifierProvider, (prev, next) {
      next.whenOrNull(
        data: (state) {
          if (state.isAuthenticated) {
            final user = state.currentUser;
            if (user != null && user.role == UserRole.owner) {
              context.go(OwnerRoutes.ownerDashboardPath);
            } else {
              context.go(AuthRoutes.profile);
            }
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(authNotifierProvider.notifier).clearError();
            context.go(AuthRoutes.login);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create account',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join Park-it to get started',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _RegisterForm(authState: authState),
              const SizedBox(height: 20),
              const SocialLoginButtons(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: context.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(authNotifierProvider.notifier).clearError();
                      context.go(AuthRoutes.login);
                    },
                    child: Text(
                      'Login',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends ConsumerStatefulWidget {
  const _RegisterForm({required this.authState});

  final AsyncValue<AppAuthState> authState;

  @override
  ConsumerState<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.driver;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final needsVerification = await ref.read(authNotifierProvider.notifier).signUp(
          _emailController.text.trim(),
          _passwordController.text,
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          _selectedRole,
        );

    if (needsVerification && mounted) {
      final phone = _phoneController.text.trim();
      if (phone.isNotEmpty) {
        // Email verification is handled via the confirmation link.
        // Now also verify phone via SMS OTP.
        context.goNamed(AuthRoutes.verifyOtp, extra: {
          'email': _emailController.text.trim(),
          'phone': phone,
        });
      } else {
        // Email-only registration: email confirmation link is sent automatically.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A confirmation link has been sent to your email. Please verify your email to log in.'),
            duration: Duration(seconds: 5),
          ),
        );
        context.go(AuthRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.authState.value?.isLoading ?? false;
    final errorMessage = widget.authState.value?.errorMessage;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _firstNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'First name',
              hintText: 'Enter your first name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppConstants.validationRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Last name',
              hintText: 'Enter your last name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppConstants.validationRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppConstants.validationRequired;
              }
              if (!RegExp(AppConstants.emailRegex).hasMatch(value.trim())) {
                return AppConstants.validationEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Phone (optional)',
              hintText: 'e.g. +212612345678',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'At least ${AppConstants.minPasswordLength} characters',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: context.colorScheme.textSecondary,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppConstants.validationRequired;
              }
              if (value.length < AppConstants.minPasswordLength) {
                return AppConstants.validationPassword;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Confirm password',
              hintText: 'Re-enter your password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: context.colorScheme.textSecondary,
                ),
                onPressed: () {
                  setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppConstants.validationRequired;
              }
              if (value != _passwordController.text) {
                return AppConstants.validationPasswordMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'I am a',
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RoleCard(
                  label: 'Driver',
                  icon: Icons.directions_car,
                  isSelected: _selectedRole == UserRole.driver,
                  onTap: () => setState(() => _selectedRole = UserRole.driver),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoleCard(
                  label: 'Owner',
                  icon: Icons.local_parking,
                  isSelected: _selectedRole == UserRole.owner,
                  onTap: () => setState(() => _selectedRole = UserRole.owner),
                ),
              ),
            ],
          ),
          if (errorMessage != null && errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.largePadding,
          horizontal: AppConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : context.colorScheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : context.colorScheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
