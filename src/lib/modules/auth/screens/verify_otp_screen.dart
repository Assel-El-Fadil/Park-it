import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';
import 'package:src/shared/widgets/custom_appbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// OTP verification screen for phone number SMS verification.
/// Email verification is handled via the confirmation link sent by Supabase.
class VerifyOtpScreen extends ConsumerStatefulWidget {
  final String? email;
  final OtpType? type;

  const VerifyOtpScreen({
    super.key,
    this.email,
    this.type,
  });

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  
  Timer? _resendTimer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  (String?, OtpType) _resolveEmailAndType() {
    final auth = ref.read(authNotifierProvider).value;
    final email = widget.email ?? auth?.pendingEmail;
    final type = widget.type ?? auth?.pendingOtpType ?? OtpType.signup;
    return (email, type);
  }

  void _startResendTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    final (emailToVerify, otpType) = _resolveEmailAndType();
    if (!_canResend || emailToVerify == null) return;
    _startResendTimer();
    
    try {
      await ref.read(authNotifierProvider.notifier).resendVerification(
        emailToVerify,
        type: otpType,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new verification email has been sent.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // 1. Strict synchronous guard to prevent any overlap in the same event loop cycle
    if (_isSubmitting) return;
    _isSubmitting = true;
    
    // 2. Clear state check
    if (!_formKey.currentState!.validate()) {
      _isSubmitting = false;
      return;
    }

    try {
      // 3. UI feedback
      final token = _codeController.text.trim();
      final (emailToVerify, otpType) = _resolveEmailAndType();

      debugPrint(
        '[VerifyOtpScreen] Submitting OTP: token=$token, email=$emailToVerify, type=$otpType',
      );

      await ref.read(authNotifierProvider.notifier).verifyOTP(
            email: emailToVerify,
            token: token,
            type: otpType,
          );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (otpType == OtpType.emailChange) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified and updated!'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh auth state
          await ref.read(authNotifierProvider.notifier).checkAuthState();
          context.go(AuthRoutes.profile);
        } else if (otpType == OtpType.recovery) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code verified! Please set your new password.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.goNamed(AuthRoutes.resetPassword);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account verified successfully! Please log in.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.goNamed(AuthRoutes.login);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      // Error is visually handled by the AuthNotifier state (errorMessage)
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.value?.isLoading ?? false;
    final errorMessage = authState.value?.errorMessage;

    final otpType =
        widget.type ?? authState.value?.pendingOtpType ?? OtpType.signup;
    final destination =
        widget.email ?? authState.value?.pendingEmail ?? 'your account';
    final instructions = otpType == OtpType.recovery
        ? 'We sent a 6-digit code to $destination. Enter it below, then you can choose a new password.'
        : otpType == OtpType.emailChange
            ? 'We sent a code to $destination to verify your new email address.'
            : 'We sent a 6-digit code to $destination. Please enter it below to verify your account.';
    final verificationLabel = 'Verification';

    return Scaffold(
      appBar: CustomAppBar(title: verificationLabel),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: AbsorbPointer(
            absorbing: _isSubmitting || isLoading,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const SizedBox(height: 24),
                Text(
                  'Enter Verification Code',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  instructions,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineMedium?.copyWith(letterSpacing: 8),
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: context.textTheme.headlineMedium?.copyWith(
                      color: context.colorScheme.textSecondary.withOpacity(0.3),
                      letterSpacing: 8,
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the code';
                    }
                    if (value.trim().length != 6) {
                      return 'Code must be 6 digits';
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
                    onPressed: (_isSubmitting || isLoading) ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Verify'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: (_canResend && !isLoading) ? _resendCode : null,
                      child: isLoading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            _canResend ? 'Resend Code' : 'Resend in ${_secondsRemaining}s',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: _canResend ? AppColors.primary : context.colorScheme.textSecondary,
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
      ),
    ),
    );
  }
}
