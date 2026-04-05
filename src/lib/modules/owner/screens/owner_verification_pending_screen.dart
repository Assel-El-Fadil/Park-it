import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/enums/app_enums.dart' hide UserRole;
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';

/// Shown while [VerificationStatus] is pending or unverified (rejected) for owners.
class OwnerVerificationPendingScreen extends ConsumerStatefulWidget {
  const OwnerVerificationPendingScreen({super.key});

  @override
  ConsumerState<OwnerVerificationPendingScreen> createState() =>
      _OwnerVerificationPendingScreenState();
}

class _OwnerVerificationPendingScreenState
    extends ConsumerState<OwnerVerificationPendingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).refreshCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.value?.currentUser;
    final v = user?.verificationStatus ?? VerificationStatus.pending;
    final isRejected = v == VerificationStatus.unverified;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verification status'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(authNotifierProvider.notifier).refreshCurrentUser(),
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              const SizedBox(height: 24),
              Icon(
                isRejected
                    ? Icons.info_outline
                    : Icons.hourglass_empty_rounded,
                size: 64,
                color: isRejected ? AppColors.warning : AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                isRejected
                    ? 'Documents need attention'
                    : 'Documents submitted',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                isRejected
                    ? 'An administrator could not verify your documents. Please submit updated documents. You cannot use owner features until your identity is verified.'
                    : 'Thank you. Your documents were received and are being reviewed. You cannot access the app as an owner until an administrator verifies your identity and ownership.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              if (isRejected) ...[
                FilledButton.icon(
                  onPressed: () {
                    context.goNamed(OwnerRoutes.ownerIdentityUpload);
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Resubmit documents'),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Pull down to refresh status after an admin has reviewed your account.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
