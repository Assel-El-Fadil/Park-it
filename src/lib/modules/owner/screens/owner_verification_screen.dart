import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/controllers/owner_verification_controller.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'dart:typed_data';

class OwnerVerificationScreen extends ConsumerWidget {
  const OwnerVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider).value;
    final user = authState?.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    final isPending = user.verificationStatus == VerificationStatus.pending;
    final isRejected = user.verificationStatus == VerificationStatus.rejected;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Identity Verification'),
        centerTitle: true,
        automaticallyImplyLeading: false, // User shouldn't navigate back from here easily
        actions: [
          IconButton(
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: isPending ? _buildPendingState(context) : _buildUploadForm(context, ref, isRejected),
      ),
    );
  }

  Widget _buildPendingState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AppCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Verification Pending',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your identity documents have been successfully submitted and are currently under review by our administration team. You will be granted access to your dashboard once verified.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondaryLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadForm(BuildContext context, WidgetRef ref, bool isRejected) {
    final state = ref.watch(ownerVerificationControllerProvider);
    final controller = ref.read(ownerVerificationControllerProvider.notifier);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRejected)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.bottom(24),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your previous submission was rejected. Please ensure the documents are clear and valid, then try again.',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),

          Text(
            'We need to verify your identity',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'To maintain a trusted community, all parking spot owners must complete identity verification. Please upload the required documents below.',
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 32),

          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.error!,
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
              ),
            ),

          _buildImageSelector(
            context,
            title: 'National ID Card (Front)',
            subtitle: 'Clear photo of the front of your ID card.',
            imageBytes: state.idFront,
            onTap: controller.pickIdFront,
          ),
          const SizedBox(height: 20),
          
          _buildImageSelector(
            context,
            title: 'National ID Card (Back)',
            subtitle: 'Clear photo of the back of your ID card.',
            imageBytes: state.idBack,
            onTap: controller.pickIdBack,
          ),
          const SizedBox(height: 20),

          Text(
            'Property Certificates',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              'Upload up to 3 property certificates proving your ownership. Must upload at least 1.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
            ),
          ),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (int i = 0; i < state.propertyCertificates.length; i++)
                _buildPropertyCertificateThumbnail(
                  context,
                  bytes: state.propertyCertificates[i],
                  onRemove: () => controller.removePropertyCertificate(i),
                ),
              if (state.propertyCertificates.length < 3)
                InkWell(
                  onTap: controller.pickPropertyCertificate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, color: theme.colorScheme.primary),
                        const SizedBox(height: 8),
                        Text('Add', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 48),
          
          PrimaryButton(
            label: state.isLoading ? 'Submitting...' : 'Submit Documents',
            onPressed: state.isLoading ? null : () async {
              final success = await controller.submitDocuments();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Documents submitted successfully!')),
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildImageSelector(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Uint8List? imageBytes,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight)),
        const SizedBox(height: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: imageBytes != null ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                width: imageBytes != null ? 2 : 1,
              ),
              image: imageBytes != null
                  ? DecorationImage(
                      image: MemoryImage(imageBytes),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageBytes == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to upload image',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(Icons.check_circle, color: Colors.white, size: 48),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCertificateThumbnail(BuildContext context, {required Uint8List bytes, required VoidCallback onRemove}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: MemoryImage(bytes),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
