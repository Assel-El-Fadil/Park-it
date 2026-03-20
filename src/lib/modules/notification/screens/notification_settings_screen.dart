import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _bookingAlerts = true;
  bool _paymentAlerts = true;
  bool _promotionalAlerts = false;
  bool _messageAlerts = true;
  bool _reviewAlerts = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notification Settings',
        automaticallyImplyLeading: true,
        centerTitle: true,
        showBottomBorder: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Channels Section
          _buildSectionTitle('Notification Channels'),
          const SizedBox(height: 8),
          _buildSwitchTile(
            'Push Notifications',
            'Receive push notifications on your device',
            Icons.notifications_active_rounded,
            _pushEnabled,
            (value) => setState(() => _pushEnabled = value),
          ),
          _buildSwitchTile(
            'Email Notifications',
            'Receive notifications via email',
            Icons.email_rounded,
            _emailEnabled,
            (value) => setState(() => _emailEnabled = value),
          ),
          _buildSwitchTile(
            'SMS Notifications',
            'Receive text message alerts',
            Icons.sms_rounded,
            _smsEnabled,
            (value) => setState(() => _smsEnabled = value),
          ),

          const SizedBox(height: 24),

          // Alert Types Section
          _buildSectionTitle('Alert Types'),
          const SizedBox(height: 8),
          _buildSwitchTile(
            'Booking Alerts',
            'Booking confirmations, reminders, and updates',
            Icons.calendar_today_rounded,
            _bookingAlerts,
            (value) => setState(() => _bookingAlerts = value),
          ),
          _buildSwitchTile(
            'Payment Alerts',
            'Payment confirmations, failures, and refunds',
            Icons.payment_rounded,
            _paymentAlerts,
            (value) => setState(() => _paymentAlerts = value),
          ),
          _buildSwitchTile(
            'Message Alerts',
            'New messages from hosts',
            Icons.message_rounded,
            _messageAlerts,
            (value) => setState(() => _messageAlerts = value),
          ),
          _buildSwitchTile(
            'Review Alerts',
            'When someone reviews your parking or you receive a review',
            Icons.star_rounded,
            _reviewAlerts,
            (value) => setState(() => _reviewAlerts = value),
          ),
          _buildSwitchTile(
            'Promotional Alerts',
            'Special offers and promotions',
            Icons.local_offer_rounded,
            _promotionalAlerts,
            (value) => setState(() => _promotionalAlerts = value),
          ),

          const SizedBox(height: 24),

          // Quiet Hours Section
          _buildSectionTitle('Quiet Hours'),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.bedtime_rounded,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Do Not Disturb',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: false,
                        onChanged: (value) {},
                        activeColor: theme.primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Text('From')),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('10:00 PM'),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('7:00 AM'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Save Button
          ElevatedButton(
            onPressed: () {
              // Save settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Save Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}
