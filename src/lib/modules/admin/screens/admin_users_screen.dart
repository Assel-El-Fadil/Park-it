import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/modules/admin/repositories/admin_repository.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/shared/widgets/app_card.dart';

final adminUsersProvider = FutureProvider.autoDispose<List<UserModel>>((ref) {
  return ref.read(adminRepositoryProvider).getNormalUsers();
});

class AdminUserSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateSearch(String val) => state = val;
}

final adminUserSearchProvider = NotifierProvider<AdminUserSearchNotifier, String>(
  AdminUserSearchNotifier.new,
);

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminUsersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => ref.read(adminUserSearchProvider.notifier).updateSearch(val),
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (users) {
          final searchQuery = ref.watch(adminUserSearchProvider).toLowerCase();
          final filteredUsers = users.where((u) {
            final fullName = '${u.firstName} ${u.lastName}'.toLowerCase();
            return fullName.contains(searchQuery);
          }).toList();

          if (filteredUsers.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminUsersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final bool isSuspended = user.isSuspended;
                final bool isBanned = user.isBanned;

                Color statusColor = Colors.green;
                String statusText = 'Active';
                if (isBanned) {
                  statusColor = Colors.red;
                  statusText = 'Banned';
                } else if (isSuspended) {
                  statusColor = Colors.orange;
                  statusText = 'Suspended';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () => _showUserActions(context, ref, user),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            user.firstName.isNotEmpty ? user.firstName[0] : '?',
                            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${user.firstName} ${user.lastName}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                user.role.name.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(color: statusColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showUserActions(BuildContext context, WidgetRef ref, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserActionsSheet(user: user, parentRef: ref),
    );
  }
}

class _UserActionsSheet extends StatefulWidget {
  const _UserActionsSheet({required this.user, required this.parentRef});
  final UserModel user;
  final WidgetRef parentRef;

  @override
  State<_UserActionsSheet> createState() => _UserActionsSheetState();
}

class _UserActionsSheetState extends State<_UserActionsSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actions for ${user.firstName}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (user.isBanned)
            _buildActionCard(
              title: 'Revoke Ban',
              subtitle: 'Allow user to access the platform again.',
              icon: Icons.check_circle_outline,
              color: Colors.green,
              onTap: () => _updateStatus(isBanned: false, isSuspended: false),
            )
          else ...[
            if (user.isSuspended)
              _buildActionCard(
                title: 'Unsuspend',
                subtitle: 'Restore user privileges.',
                icon: Icons.check_circle_outline,
                color: Colors.green,
                onTap: () => _updateStatus(isSuspended: false),
              )
            else
              _buildActionCard(
                title: 'Suspend',
                subtitle: 'Temporarily restrict user access.',
                icon: Icons.pause_circle_outline,
                color: Colors.orange,
                onTap: () => _updateStatus(isSuspended: true),
              ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: 'Ban Permanent',
              subtitle: 'Permanently remove user from platform.',
              icon: Icons.block,
              color: AppColors.error,
              onTap: () => _updateStatus(isBanned: true, isSuspended: false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: _isLoading ? null : onTap,
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: color.withOpacity(0.8))),
        trailing: _isLoading
            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.chevron_right),
      ),
    );
  }

  Future<void> _updateStatus({bool? isSuspended, bool? isBanned}) async {
    setState(() => _isLoading = true);
    try {
      await widget.parentRef.read(adminRepositoryProvider).updateUserStatus(
            userId: widget.user.id,
            isSuspended: isSuspended,
            isBanned: isBanned,
          );
      widget.parentRef.invalidate(adminUsersProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User status updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
