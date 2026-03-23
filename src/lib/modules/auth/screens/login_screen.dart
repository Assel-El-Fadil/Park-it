import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';
import 'package:src/modules/auth/widgets/social_login_buttons.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AsyncValue<AppAuthState>>(authNotifierProvider, (prev, next) {
      next.whenOrNull(
        data: (state) {
          if (state.isAuthenticated) {
            context.go(AuthRoutes.profile);
          }
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Text(
                'Welcome back',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _LoginForm(authState: authState),
              const SizedBox(height: 20),
              const SocialLoginButtons(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: context.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(authNotifierProvider.notifier).clearError();
                      context.go(AuthRoutes.register);
                    },
                    child: Text(
                      'Register',
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

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm({required this.authState});

  final AsyncValue<AppAuthState> authState;

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

enum _LoginIdentifierType { email, phone }

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  _LoginIdentifierType _identifierType = _LoginIdentifierType.email;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).signIn(
          _identifierController.text.trim(),
          _passwordController.text,
        );
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
          Row(
            children: [
              Expanded(
                child: SegmentedButton<_LoginIdentifierType>(
                  segments: const [
                    ButtonSegment(
                      value: _LoginIdentifierType.email,
                      icon: Icon(Icons.email_outlined),
                      label: Text('Email'),
                    ),
                    ButtonSegment(
                      value: _LoginIdentifierType.phone,
                      icon: Icon(Icons.phone_outlined),
                      label: Text('Phone'),
                    ),
                  ],
                  selected: {_identifierType},
                  onSelectionChanged: (Set<_LoginIdentifierType> selected) {
                    setState(() => _identifierType = selected.first);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _identifierController,
            keyboardType: _identifierType == _LoginIdentifierType.email
                ? TextInputType.emailAddress
                : TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: _identifierType == _LoginIdentifierType.email ? 'Email' : 'Phone',
              hintText: _identifierType == _LoginIdentifierType.email
                  ? 'Enter your email'
                  : 'Enter your phone number',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppConstants.validationRequired;
              }
              if (_identifierType == _LoginIdentifierType.email) {
                if (!RegExp(AppConstants.emailRegex).hasMatch(value.trim())) {
                  return AppConstants.validationEmail;
                }
              } else {
                if (!RegExp(AppConstants.phoneRegex).hasMatch(value.trim())) {
                  return AppConstants.validationPhone;
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
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
              return null;
            },
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).clearError();
                context.goNamed(AuthRoutes.forgotPassword);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
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
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}
