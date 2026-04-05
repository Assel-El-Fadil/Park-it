import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';

/// Collects national ID (front/back) and property certificates, uploads to storage,
/// and stores comma-separated public URLs in [users.identity_doc].
class OwnerIdentityUploadScreen extends ConsumerStatefulWidget {
  const OwnerIdentityUploadScreen({super.key});

  @override
  ConsumerState<OwnerIdentityUploadScreen> createState() =>
      _OwnerIdentityUploadScreenState();
}

class _OwnerIdentityUploadScreenState
    extends ConsumerState<OwnerIdentityUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _idFront;
  XFile? _idBack;
  final List<XFile> _propertyCerts = [];

  Future<void> _pickSingle(void Function(XFile?) setFile) async {
    final f = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
    );
    if (f != null) setState(() => setFile(f));
  }

  Future<void> _pickPropertyBatch() async {
    final list = await _picker.pickMultiImage(imageQuality: 65);
    if (list.isNotEmpty) {
      setState(() => _propertyCerts.addAll(list));
    }
  }

  Future<void> _submit() async {
    if (_idFront == null || _idBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add both sides of your national ID.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_propertyCerts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one property certificate image.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final frontBytes = await _idFront!.readAsBytes();
      final backBytes = await _idBack!.readAsBytes();
      final propBytes = <Uint8List>[];
      for (final x in _propertyCerts) {
        propBytes.add(await x.readAsBytes());
      }

      await ref.read(authNotifierProvider.notifier).submitOwnerIdentityDocuments(
            idFrontBytes: frontBytes,
            idBackBytes: backBytes,
            propertyCertificateBytes: propBytes,
          );

      if (mounted) {
        context.goNamed(OwnerRoutes.ownerVerificationPending);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.value?.currentUser;
    final isLoading = auth.value?.isLoading ?? false;
    final err = auth.value?.errorMessage;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Owner verification'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    },
              child: const Text('Sign out'),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upload your documents',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We need a photo of your national ID (front and back) and one or more images of your property certificate. Images are saved with your account for admin review (no external file hosting). Use smaller photos if upload fails.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 24),
                _DocTile(
                  title: 'National ID — front (recto)',
                  file: _idFront,
                  onPick: () => _pickSingle((f) => _idFront = f),
                  onClear: () => setState(() => _idFront = null),
                ),
                const SizedBox(height: 12),
                _DocTile(
                  title: 'National ID — back (verso)',
                  file: _idBack,
                  onPick: () => _pickSingle((f) => _idBack = f),
                  onClear: () => setState(() => _idBack = null),
                ),
                const SizedBox(height: 12),
                Text(
                  'Property certificates',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _pickPropertyBatch,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Add images (no limit)'),
                ),
                if (_propertyCerts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...List.generate(_propertyCerts.length, (i) {
                    final x = _propertyCerts[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.description_outlined),
                      title: Text(x.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: isLoading
                            ? null
                            : () => setState(() => _propertyCerts.removeAt(i)),
                      ),
                    );
                  }),
                ],
                if (err != null && err.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(err, style: const TextStyle(color: AppColors.error)),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit for review'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.title,
    required this.file,
    required this.onPick,
    required this.onClear,
  });

  final String title;
  final XFile? file;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(file == null ? 'Choose image' : 'Replace'),
                  ),
                ),
                if (file != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
            if (file != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  file!.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
