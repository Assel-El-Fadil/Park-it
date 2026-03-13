import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialLoginButtons extends ConsumerWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.value?.isLoading ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Or continue with',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                onTap: isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).signInWithOAuth(
                          OAuthProvider.google,
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Facebook',
                icon: Icons.facebook,
                onTap: isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier).signInWithOAuth(
                          OAuthProvider.facebook,
                        ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Instagram',
                icon: Icons.camera_alt_outlined,
                onTap: isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Instagram sign-in is not available. Use Facebook or Google.',
                            ),
                          ),
                        );
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: context.colorScheme.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: context.colorScheme.onSurface),
          const SizedBox(width: 8),
          Text(label, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}
