import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/enums/app_enums.dart' hide UserRole;
import 'package:src/modules/admin/repositories/admin_repository.dart';
import 'package:src/modules/admin/screens/admin_users_screen.dart';
import 'package:src/modules/auth/models/user_model.dart';

final adminUserByIdProvider =
    FutureProvider.autoDispose.family<UserModel, String>((ref, userId) {
  return ref.read(adminRepositoryProvider).getUserById(userId);
});

class AdminOwnerVerificationScreen extends ConsumerWidget {
  const AdminOwnerVerificationScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(adminUserByIdProvider(userId));

    return asyncUser.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Verification')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (user) => _VerificationBody(user: user, userId: userId),
    );
  }
}

class _VerificationBody extends ConsumerStatefulWidget {
  const _VerificationBody({required this.user, required this.userId});

  final UserModel user;
  final String userId;

  @override
  ConsumerState<_VerificationBody> createState() =>
      _VerificationBodyState();
}

class _VerificationBodyState extends ConsumerState<_VerificationBody> {
  bool _busy = false;

  List<String> get _urls {
    final raw = widget.user.identityDoc?.trim();
    if (raw == null || raw.isEmpty) return [];
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String _labelForIndex(int i) {
    if (i == 0) return 'National ID — front';
    if (i == 1) return 'National ID — back';
    return 'Property certificate ${i - 1}';
  }

  Future<void> _setStatus(VerificationStatus status) async {
    setState(() => _busy = true);
    try {
      await ref.read(adminRepositoryProvider).updateOwnerVerificationStatus(
            userId: widget.userId,
            status: status,
          );
      ref.invalidate(adminUserByIdProvider(widget.userId));
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == VerificationStatus.verified
                  ? 'Owner verified.'
                  : 'Owner marked as unverified.',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;

    return Scaffold(
      appBar: AppBar(
        title: Text('Verify ${widget.user.firstName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${widget.user.firstName} ${widget.user.lastName}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            widget.user.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(
              'Status: ${widget.user.verificationStatus.toJson()}',
            ),
          ),
          const SizedBox(height: 16),
          if (urls.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No documents uploaded yet.'),
            )
          else
            ...List.generate(urls.length, (i) {
              final segment = urls[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labelForIndex(i),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: _IdentityDocImage(segment: segment),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy || urls.isEmpty
                      ? null
                      : () => _setStatus(VerificationStatus.verified),
                  child: const Text('Verify'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _setStatus(VerificationStatus.unverified),
                  child: const Text('Reject'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Renders either a legacy http(s) URL or a base64-encoded image (new submissions).
class _IdentityDocImage extends StatelessWidget {
  const _IdentityDocImage({required this.segment});

  final String segment;

  @override
  Widget build(BuildContext context) {
    final t = segment.trim();
    if (t.startsWith('http://') || t.startsWith('https://')) {
      return Image.network(
        t,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Text('Could not load image'),
        ),
      );
    }
    try {
      final bytes = base64Decode(t);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } catch (_) {
      return Container(
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Text('Could not decode image'),
      );
    }
  }
}
