import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

/// Screen shown after clicking the password reset link in the email.
/// The user enters and confirms a new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authNotifierProvider.notifier).updatePassword(
            newPassword: _passwordController.text,
          );
      setState(() => _isSuccess = true);
    } catch (e) {
      // Error handled by AuthNotifier state
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.value?.isLoading ?? false;
    final errorMessage = authState.value?.errorMessage;

    return Scaffold(
      appBar: const CustomAppBar(title: 'New Password'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: _isSuccess
              ? _buildSuccessView(context)
              : _buildFormView(context, isLoading, errorMessage),
        ),
      ),
    );
  }

  Widget _buildFormView(BuildContext context, bool isLoading, String? errorMessage) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Create a new password',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your new password must be at least ${AppConstants.minPasswordLength} characters long.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'Enter new password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: context.colorScheme.textSecondary,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter new password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  color: context.colorScheme.textSecondary,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
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
          if (errorMessage != null && errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
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
                  : const Text('Update Password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Password Updated!',
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your password has been successfully updated.\nYou can now log in with your new password.',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go(AuthRoutes.login),
            child: const Text('Go to Login'),
          ),
        ),
      ],
    );
  }
}
