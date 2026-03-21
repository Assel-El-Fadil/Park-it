import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/notification/models/notification_model.dart';
import 'package:src/providers/notification_provider.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  final int notificationId;
  final NotificationModel? notification;

  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
    this.notification,
  });

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Mark as read when viewed
    if (widget.notification != null && !widget.notification!.isRead) {
      ref.read(notificationProvider.notifier).markAsRead(widget.notificationId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get notification from provider if not passed directly
    final notifications = ref.watch(notificationProvider);
    final notification =
        widget.notification ??
        notifications.firstWhere((n) => n.id == widget.notificationId);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Notification Details',
        automaticallyImplyLeading: true,
        centerTitle: true,
        showBottomBorder: false,
        actions: [
          // Mark as unread toggle
          IconButton(
            icon: Icon(
              notification.isRead
                  ? Icons.mark_chat_read_rounded
                  : Icons.mark_chat_unread_rounded,
            ),
            onPressed: _toggleReadStatus,
            tooltip: notification.isRead ? 'Mark as unread' : 'Mark as read',
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _showDeleteDialog,
            tooltip: 'Delete',
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _showShareOptions,
            tooltip: 'Share',
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and type
                  _buildHeader(notification, theme),

                  const SizedBox(height: 24),

                  // Main content
                  _buildContent(notification, theme),

                  const SizedBox(height: 24),

                  // Metadata section
                  _buildMetadata(notification, theme),

                  const SizedBox(height: 24),

                  // Reference/action buttons based on type
                  _buildActionButtons(notification, theme),

                  const SizedBox(height: 16),

                  // Additional actions based on type
                  _buildAdditionalActions(notification, theme),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(NotificationModel notification, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notification.type.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: notification.type.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Large icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: notification.type.color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              notification.type.icon,
              size: 35,
              color: notification.type.color,
            ),
          ),
          const SizedBox(width: 20),

          // Type and title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: notification.type.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    notification.type.titlePrefix.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: notification.type.color,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  notification.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NotificationModel notification, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Message',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            notification.content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(NotificationModel notification, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildMetadataRow(
            Icons.access_time_rounded,
            'Received',
            _formatFullDateTime(notification.createdAt),
            theme,
          ),
          if (notification.sentAt != null) ...[
            const SizedBox(height: 16),
            _buildMetadataRow(
              Icons.send_rounded,
              'Sent',
              _formatFullDateTime(notification.sentAt!),
              theme,
            ),
          ],
          const SizedBox(height: 16),
          _buildMetadataRow(
            Icons.info_outline_rounded,
            'Channel',
            notification.channel.toString().split('.').last,
            theme,
            valueColor: _getChannelColor(notification.channel),
          ),
          if (notification.referenceId != null) ...[
            const SizedBox(height: 16),
            _buildMetadataRow(
              Icons.link_rounded,
              'Reference',
              '${notification.referenceType} #${notification.referenceId}',
              theme,
              valueColor: Colors.blue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: theme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600])),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(NotificationModel notification, ThemeData theme) {
    // Determine primary action based on notification type
    final primaryAction = _getPrimaryAction(notification);

    if (primaryAction == null) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () => _handlePrimaryAction(notification, primaryAction),
            icon: Icon(primaryAction.icon),
            label: Text(
              primaryAction.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalActions(
    NotificationModel notification,
    ThemeData theme,
  ) {
    final secondaryActions = _getSecondaryActions(notification);

    if (secondaryActions.isEmpty) return const SizedBox.shrink();

    return Column(
      children: secondaryActions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => _handleSecondaryAction(notification, action),
              icon: Icon(action.icon, size: 18),
              label: Text(action.label),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helper methods for actions
  NotificationAction? _getPrimaryAction(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingReminder:
      case NotificationType.bookingCancelled:
        return NotificationAction(
          label: 'View Booking',
          icon: Icons.calendar_today_rounded,
          type: 'booking',
        );

      case NotificationType.paymentReceived:
      case NotificationType.paymentFailed:
      case NotificationType.refundProcessed:
        return NotificationAction(
          label: 'View Payment',
          icon: Icons.payment_rounded,
          type: 'payment',
        );

      case NotificationType.reviewReceived:
        return NotificationAction(
          label: 'View Review',
          icon: Icons.star_rounded,
          type: 'review',
        );

      case NotificationType.messageReceived:
        return NotificationAction(
          label: 'Reply to Message',
          icon: Icons.reply_rounded,
          type: 'message',
        );

      case NotificationType.promotion:
      case NotificationType.specialOffer:
        return NotificationAction(
          label: 'View Offer',
          icon: Icons.local_offer_rounded,
          type: 'promo',
        );

      case NotificationType.parkingUnavailable:
        return NotificationAction(
          label: 'Find Alternative',
          icon: Icons.search_rounded,
          type: 'search',
        );

      case NotificationType.hostResponse:
        return NotificationAction(
          label: 'Contact Host',
          icon: Icons.person_rounded,
          type: 'host',
        );

      default:
        return null;
    }
  }

  List<NotificationAction> _getSecondaryActions(
    NotificationModel notification,
  ) {
    final actions = <NotificationAction>[];

    switch (notification.type) {
      case NotificationType.bookingConfirmed:
      case NotificationType.bookingReminder:
        actions.add(
          NotificationAction(
            label: 'Get Directions',
            icon: Icons.directions_car_rounded,
            type: 'directions',
          ),
        );
        actions.add(
          NotificationAction(
            label: 'Contact Host',
            icon: Icons.message_rounded,
            type: 'contact',
          ),
        );
        break;

      case NotificationType.paymentFailed:
        actions.add(
          NotificationAction(
            label: 'Update Payment Method',
            icon: Icons.credit_card_rounded,
            type: 'update_payment',
          ),
        );
        break;

      case NotificationType.promotion:
      case NotificationType.specialOffer:
        actions.add(
          NotificationAction(
            label: 'Share Offer',
            icon: Icons.share_rounded,
            type: 'share',
          ),
        );
        actions.add(
          NotificationAction(
            label: 'Save for Later',
            icon: Icons.bookmark_border_rounded,
            type: 'save',
          ),
        );
        break;

      case NotificationType.reviewReceived:
        actions.add(
          NotificationAction(
            label: 'Respond to Review',
            icon: Icons.reply_rounded,
            type: 'respond',
          ),
        );
        break;

      default:
        break;
    }

    // Add common actions
    actions.add(
      NotificationAction(
        label: 'Report Issue',
        icon: Icons.flag_rounded,
        type: 'report',
      ),
    );

    return actions;
  }

  Future<void> _handlePrimaryAction(
    NotificationModel notification,
    NotificationAction action,
  ) async {
    setState(() => _isProcessing = true);

    switch (action.type) {
      case 'booking':
        if (notification.referenceId != null) {
          // context.pushNamed(
          //   AppRoutes.bookingDetails,
          //   pathParameters: {'id': notification.referenceId.toString()},
          // );
        }
        break;

      case 'payment':
        if (notification.referenceId != null) {
          // context.pushNamed(
          //   AppRoutes.paymentDetails,
          //   pathParameters: {'id': notification.referenceId.toString()},
          // );
        }
        break;

      case 'review':
        if (notification.referenceId != null) {
          // context.pushNamed(
          //   AppRoutes.reviewDetails,
          //   pathParameters: {'id': notification.referenceId.toString()},
          // );
        }
        break;

      case 'message':
        if (notification.referenceId != null) {
          // context.pushNamed(
          //   AppRoutes.messages,
          //   extra: {'conversationId': notification.referenceId},
          // );
        }
        break;

      case 'search':
        // context.pushNamed(AppRoutes.search);
        break;

      case 'host':
        // context.pushNamed(AppRoutes.contactHost);
        break;
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _handleSecondaryAction(
    NotificationModel notification,
    NotificationAction action,
  ) async {
    setState(() => _isProcessing = true);

    switch (action.type) {
      case 'directions':
        // Navigate to directions screen
        // context.pushNamed(AppRoutes.navigation);
        break;

      case 'contact':
        // Open chat
        // context.pushNamed(AppRoutes.messages);
        break;

      case 'update_payment':
        // context.pushNamed(AppRoutes.paymentMethods);
        break;

      case 'share':
        _showShareOptions();
        break;

      case 'save':
        _saveOffer();
        break;

      case 'respond':
        // Open review response
        break;

      case 'report':
        _showReportDialog();
        break;
    }

    setState(() => _isProcessing = false);
  }

  // UI Helper methods
  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getChannelColor(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.push:
        return Colors.blue;
      case NotificationChannel.email:
        return Colors.purple;
      // case NotificationChannel.sms:
      //   return Colors.green;
      case NotificationChannel.inApp:
        return Colors.orange;
    }
  }

  void _toggleReadStatus() {
    final notifier = ref.read(notificationProvider.notifier);
    if (widget.notification!.isRead) {
      // Can't easily mark as unread without storing state
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot mark as unread'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      notifier.markAsRead(widget.notificationId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Marked as read'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(notificationProvider.notifier)
                  .deleteNotification(widget.notificationId);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Share Notification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share as Text'),
              onTap: () {
                Navigator.pop(context);
                _shareAsText();
              },
            ),
            ListTile(
              leading: const Icon(Icons.screenshot_rounded),
              title: const Text('Take Screenshot'),
              onTap: () {
                Navigator.pop(context);
                _takeScreenshot();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_rounded),
              title: const Text('Forward via Email'),
              onTap: () {
                Navigator.pop(context);
                _forwardViaEmail();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text(
          'Please describe the issue with this notification:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Thank you for your report. We\'ll look into it.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _shareAsText() {
    // Implement sharing logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shared successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _takeScreenshot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Screenshot saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _forwardViaEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email client...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveOffer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Offer saved to your account'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Helper class for actions
class NotificationAction {
  final String label;
  final IconData icon;
  final String type;

  NotificationAction({
    required this.label,
    required this.icon,
    required this.type,
  });
}
