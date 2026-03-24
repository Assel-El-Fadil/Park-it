import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/super_admin/routes/super_admin_routes.dart';

// Mock data for admins - replace with actual data fetching
class MockAdminData {
  static List<UserModel> getAdmins() {
    return [
      UserModel(
        id: '1',
        email: 'admin1@parkit.com',
        firstName: 'John',
        lastName: 'Doe',
        role: UserRole.admin,
        averageRating: 4.5,
        totalReviews: 12,
      ),
      UserModel(
        id: '2',
        email: 'admin2@parkit.com',
        firstName: 'Jane',
        lastName: 'Smith',
        role: UserRole.admin,
        averageRating: 4.8,
        totalReviews: 8,
      ),
      UserModel(
        id: '3',
        email: 'admin3@parkit.com',
        firstName: 'Bob',
        lastName: 'Johnson',
        role: UserRole.admin,
        averageRating: 4.2,
        totalReviews: 5,
      ),
    ];
  }
}

class SuperAdminAdminsScreen extends ConsumerStatefulWidget {
  const SuperAdminAdminsScreen({super.key});

  @override
  ConsumerState<SuperAdminAdminsScreen> createState() => _SuperAdminAdminsScreenState();
}

class _SuperAdminAdminsScreenState extends ConsumerState<SuperAdminAdminsScreen> {
  List<UserModel> admins = MockAdminData.getAdmins();

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
      body: SafeArea(
        child: Column(
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
              child: admins.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                      itemCount: admins.length,
                      itemBuilder: (context, index) {
                        final admin = admins[index];
                        return _AdminCard(
                          admin: admin,
                          onDelete: () => _showDeleteDialog(admin),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(UserModel admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete admin ${admin.firstName} ${admin.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                admins.removeWhere((a) => a.id == admin.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Admin ${admin.firstName} ${admin.lastName} deleted')),
              );
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

  final UserModel admin;
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            '${admin.firstName[0]}${admin.lastName[0]}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${admin.firstName} ${admin.lastName}',
          style: AppTextStyles.titleMedium.copyWith(
            color: context.colorScheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              admin.email ?? 'No email',
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
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
