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

  @override
  void initState() {
    super.initState();
    _startResendTimer();
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
    if (!_canResend || widget.email == null) return;
    _startResendTimer();
    
    try {
      await ref.read(authNotifierProvider.notifier).resendVerification(
        widget.email!,
        type: widget.type ?? OtpType.signup,
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
    if (!_formKey.currentState!.validate()) return;

    try {
      debugPrint('[VerifyOtpScreen] Submitting OTP: token=${_codeController.text.trim()}, email=${widget.email}, type=${widget.type ?? "signup"}');

      await ref.read(authNotifierProvider.notifier).verifyOTP(
            email: widget.email,
            token: _codeController.text.trim(),
            type: widget.type ?? OtpType.signup,
          );

      if (mounted) {
        if (widget.type == OtpType.emailChange) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified and updated!'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh auth state
          await ref.read(authNotifierProvider.notifier).checkAuthState();
          context.go(AuthRoutes.profile);
        } else if (widget.type == OtpType.recovery) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code verified! Please set your new password.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AuthRoutes.resetPasswordPath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account verified successfully! Please log in.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(AuthRoutes.login);
        }
      }
    } catch (e) {
      // Error handled by AuthNotifier state
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.value?.isLoading ?? false;
    final errorMessage = authState.value?.errorMessage;

    final destination = widget.email ?? 'your account';
    final verificationLabel = 'Verification';

    return Scaffold(
      appBar: CustomAppBar(title: verificationLabel),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                  'We sent a 6-digit code to $destination. Please enter it below to verify your account.',
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
                      onPressed: _canResend ? _resendCode : null,
                      child: Text(
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
    );
  }
}
