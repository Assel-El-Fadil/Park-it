import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/super_admin/routes/super_admin_routes.dart';
import 'package:src/modules/super_admin/services/super_admin_service.dart';

class SuperAdminAdminsScreen extends ConsumerStatefulWidget {
  const SuperAdminAdminsScreen({super.key});

  @override
  ConsumerState<SuperAdminAdminsScreen> createState() => _SuperAdminAdminsScreenState();
}

class _SuperAdminAdminsScreenState extends ConsumerState<SuperAdminAdminsScreen> {
  final SuperAdminService _service = SuperAdminService();
  List<Map<String, dynamic>> admins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  Future<void> _loadAdmins() async {
    print('DEBUG: Starting to load admins...');
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedAdmins = await _service.getAdmins();
      print('DEBUG: Fetched ${fetchedAdmins.length} admins');
      print('DEBUG: Admins data: $fetchedAdmins');
      
      if (mounted) {
        setState(() {
          admins = fetchedAdmins;
          _isLoading = false;
        });
        print('DEBUG: State updated with ${admins.length} admins');
      }
    } catch (e, stackTrace) {
      print('DEBUG: Error loading admins: $e');
      print('DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading admins: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _initial(String? value, {String fallback = 'A'}) {
    final safe = (value ?? '').trim();
    if (safe.isEmpty) return fallback;
    return safe[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Admins',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.textPrimary,
          ),
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : admins.isEmpty
              ? _EmptyState()
              : Column(
                  children: [
                    // Header with add button
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${admins.length} Admins',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: context.colorScheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.pushNamed(SuperAdminRoutes.addAdmin);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Admin'),
                          ),
                        ],
                      ),
                    ),
                    
                    // Admins List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadAdmins,
                        child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final admin = admins[index];
                                    return _AdminCard(
                                      admin: admin,
                                      onDelete: () => _showDeleteDialog(admin),
                                    );
                                  },
                                  childCount: admins.length,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete admin ${admin['first_name'] ?? ''} ${admin['last_name'] ?? ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _service.deleteAdmin(admin['id']);
              if (success) {
                setState(() {
                  admins.removeWhere((a) => a['id'] == admin['id']);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Admin ${admin['first_name']} ${admin['last_name']} deleted')),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete admin'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 64,
              color: context.colorScheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No admins yet',
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first admin to get started.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.pushNamed(SuperAdminRoutes.addAdmin);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Admin'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  const _AdminCard({
    required this.admin,
    required this.onDelete,
  });

  final Map<String, dynamic> admin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                '${_initial(admin['first_name'] as String?, fallback: 'A')}${_initial(admin['last_name'] as String?, fallback: 'D')}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            
            // Admin Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${admin['first_name'] ?? 'Admin'} ${admin['last_name'] ?? 'User'}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: context.colorScheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    admin['email'] ?? 'No email',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admin account',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.colorScheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
