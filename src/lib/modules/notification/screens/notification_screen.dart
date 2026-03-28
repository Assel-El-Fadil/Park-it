import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/notification/models/notification_model.dart';
import 'package:src/modules/notification/routes/notification_routes.dart';
import 'package:src/modules/notification/widgets/notification_filter_chip.dart';
import 'package:src/modules/notification/widgets/notification_tile.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/reservation/routes/reservation_routes.dart';
import 'package:src/modules/review/routes/review_routes.dart';
import 'package:src/providers/notification_provider.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _isSelectionMode = false;
  Set<int> _selectedIds = {};
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifications = ref.watch(notificationProvider);
    final filterType = ref.watch(notificationFilterProvider);
    final unreadCount = ref.read(notificationProvider.notifier).unreadCount;

    // Filter notifications based on search and filter
    final filteredNotifications = _filterNotifications(
      notifications,
      filterType,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme, unreadCount),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(theme),

          // Filter Chips
          _buildFilterChips(),

          // Notification List
          Expanded(
            child: filteredNotifications.isEmpty
                ? _buildEmptyState(theme)
                : _buildNotificationList(filteredNotifications),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? _buildSelectionFAB() : null,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, int unreadCount) {
    return CustomAppBar(
      title: 'Notifications',
      automaticallyImplyLeading: true,
      centerTitle: false,
      showBottomBorder: false,
      actions: [
        if (!_isSelectionMode) ...[
          // Mark all as read button
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              onPressed: _showMarkAllReadDialog,
              tooltip: 'Mark all as read',
            ),

          // Filter menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  AppNavigator.pushNamed(
                    context,
                    NotificationRoutes.notificationSettings,
                  );
                  break;
                case 'select':
                  setState(() {
                    _isSelectionMode = true;
                  });
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'select',
                child: Row(
                  children: [
                    Icon(Icons.check_box_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Select'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Selection mode actions
          IconButton(
            icon: const Icon(Icons.select_all_rounded),
            onPressed: _selectAll,
            tooltip: 'Select all',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
            tooltip: 'Delete selected',
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _exitSelectionMode,
            tooltip: 'Cancel',
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          NotificationFilterChip(
            label: 'All',
            icon: Icons.notifications_rounded,
            isSelected: ref.watch(notificationFilterProvider) == null,
            onSelected: (selected) {
              ref.read(notificationFilterProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          NotificationFilterChip(
            label: 'Unread',
            icon: Icons.mark_unread_chat_alt_rounded,
            isSelected: false, // Special filter
            onSelected: (selected) {
              // Handle unread filter
            },
          ),
          const SizedBox(width: 8),
          ...NotificationType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: NotificationFilterChip(
                label: type.titlePrefix.split(' ').first,
                icon: type.icon,
                color: type.color,
                isSelected: ref.watch(notificationFilterProvider) == type,
                onSelected: (selected) {
                  ref.read(notificationFilterProvider.notifier).state = selected
                      ? type
                      : null;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    // Group notifications by date
    final grouped = _groupNotificationsByDate(notifications);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final dateNotifications = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                date,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...dateNotifications.map((notification) {
              return NotificationTile(
                notification: notification,
                isSelected: _selectedIds.contains(notification.id),
                isSelectionMode: _isSelectionMode,
                onTap: () => _handleNotificationTap(notification),
                onLongPress: () => _handleLongPress(notification),
                onCheckboxChanged: (selected) {
                  setState(() {
                    if (notification.id == null) return;
                    if (selected) {
                      _selectedIds.add(notification.id!);
                    } else {
                      _selectedIds.remove(notification.id!);
                    }
                  });
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 60,
              color: theme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!\nCheck back later for updates',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionFAB() {
    return FloatingActionButton(
      onPressed: _selectedIds.length == _selectedIds.length ? null : _selectAll,
      child: Text('${_selectedIds.length}'),
    );
  }

  // Helper methods
  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications,
    NotificationType? filterType,
  ) {
    return notifications.where((n) {
      // Filter by type
      if (filterType != null && n.type != filterType) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        return n.title.toLowerCase().contains(_searchQuery) ||
            n.content.toLowerCase().contains(_searchQuery);
      }

      return true;
    }).toList();
  }

  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> notifications,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    Map<String, List<NotificationModel>> grouped = {};

    for (var notification in notifications) {
      String dateKey;
      final notificationDate = DateTime(
        notification.createdAt!.year,
        notification.createdAt!.month,
        notification.createdAt!.day,
      );

      if (notificationDate == today) {
        dateKey = 'Today';
      } else if (notificationDate == yesterday) {
        dateKey = 'Yesterday';
      } else if (notificationDate.isAfter(thisWeek)) {
        dateKey = 'This Week';
      } else {
        dateKey = 'Earlier';
      }

      grouped.putIfAbsent(dateKey, () => []).add(notification);
    }

    return grouped;
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (_isSelectionMode) {
      setState(() {
        if (notification.id == null) return;
        if (_selectedIds.contains(notification.id!)) {
          _selectedIds.remove(notification.id!);
        } else {
          _selectedIds.add(notification.id!);
        }
      });
    } else {
      // Mark as read
      if (notification.id != null) {
        ref.read(notificationProvider.notifier).markAsRead(notification.id!);
      }

      // Navigate based on reference type
      if (notification.referenceType != null &&
          notification.referenceId != null) {
        switch (notification.referenceType) {
          case 'booking':
            AppNavigator.pushNamed(
              context,
              ReservationRoutes.reservationDetail,
              pathParameters: {'id': notification.referenceId.toString()},
            );
            break;
          case 'payment':
            AppNavigator.pushNamed(
              context,
              PaymentRoutes.paymentDetails,
              extra: notification.referenceId,
            );
            break;
          case 'review':
            AppNavigator.pushNamed(
              context,
              ReviewRoutes.reviewDetailPath,
              pathParameters: {'id': notification.referenceId.toString()},
            );
            break;
        }
      } else {
        // Show notification details
        _showNotificationDetails(notification);
      }
    }
  }

  void _handleLongPress(NotificationModel notification) {
    if (notification.id == null) return;
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(notification.id!);
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds = {
        ...filteredNotifications.where((n) => n.id != null).map((n) => n.id!),
      };
    });
  }

  void _deleteSelected() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notifications'),
        content: Text(
          'Are you sure you want to delete ${_selectedIds.length} notification(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (var id in _selectedIds) {
                ref.read(notificationProvider.notifier).deleteNotification(id);
              }
              _exitSelectionMode();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  void _showMarkAllReadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text(
          'Are you sure you want to mark all notifications as read?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationProvider.notifier).markAllAsRead();
              Navigator.pop(context);
            },
            child: const Text('Mark All'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: notification.type.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notification.type.icon,
                        color: notification.type.color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.type.titlePrefix,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  notification.content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Received ${notification.timeAgo}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (notification.referenceType != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleNotificationTap(notification);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('View ${notification.referenceType}'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<NotificationModel> get filteredNotifications {
    final notifications = ref.watch(notificationProvider);
    return _filterNotifications(
      notifications,
      ref.watch(notificationFilterProvider),
    );
  }
}
