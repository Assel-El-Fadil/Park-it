import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

enum FailureType {
  paymentDeclined,
  insufficientFunds,
  parkingUnavailable,
  timeout,
  networkError,
  serverError,
  duplicateBooking,
  invalidPaymentMethod,
}

class BookingFailureScreen extends ConsumerWidget {
  final FailureType? failureType;
  final String? customMessage;
  final ReservationModel? booking;
  final String? errorCode;

  const BookingFailureScreen({
    super.key,
    this.failureType,
    this.customMessage,
    this.booking,
    this.errorCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final failureConfig = _getFailureConfig(failureType);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Booking Failed',
        automaticallyImplyLeading: true,
        centerTitle: true,
        showBottomBorder: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Animated Failure Icon
            _buildFailureIcon(theme, failureConfig),

            const SizedBox(height: 32),

            // Failure Title
            Text(
              failureConfig.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: failureConfig.color,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Failure Message
            Text(
              customMessage ?? failureConfig.message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            if (errorCode != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Error Code: $errorCode',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Suggestions based on failure type
            _buildSuggestions(theme, failureType),

            const SizedBox(height: 40),

            // Action Buttons
            _buildActionButtons(context, theme, failureType),

            const SizedBox(height: 24),

            // Help Section
            _buildHelpSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureIcon(ThemeData theme, FailureConfig config) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing animation container
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                width: 100 * value,
                height: 100 * value,
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          // Main icon
          Icon(config.icon, size: 60, color: config.color),
        ],
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme, FailureType? failureType) {
    List<String> suggestions = [];

    switch (failureType) {
      case FailureType.paymentDeclined:
        suggestions = [
          'Try a different payment method',
          'Contact your bank for more information',
          'Verify your card details are correct',
        ];
        break;
      case FailureType.insufficientFunds:
        suggestions = [
          'Add funds to your account',
          'Try a different payment method',
          'Check your account balance',
        ];
        break;
      case FailureType.parkingUnavailable:
        suggestions = [
          'Try booking for a different time slot',
          'Browse other parking spaces nearby',
          'Contact the host for availability',
        ];
        break;
      case FailureType.timeout:
        suggestions = [
          'Check your internet connection',
          'Try again in a few moments',
          'Your payment may still be processing',
        ];
        break;
      case FailureType.networkError:
        suggestions = [
          'Check your internet connection',
          'Make sure you have stable network',
          'Try using WiFi instead of mobile data',
        ];
        break;
      case FailureType.serverError:
        suggestions = [
          'Try again in a few minutes',
          'Check if the app needs an update',
          'Contact support if issue persists',
        ];
        break;
      case FailureType.duplicateBooking:
        suggestions = [
          'Check your existing bookings',
          'Choose a different time slot',
          'Contact support if you believe this is an error',
        ];
        break;
      case FailureType.invalidPaymentMethod:
        suggestions = [
          'Add a new payment method',
          'Verify your card expiration date',
          'Check CVV and card number',
        ];
        break;
      default:
        suggestions = [
          'Check your payment details',
          'Ensure you have stable internet',
          'Try again in a few moments',
        ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggestions:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...suggestions.map(
          (suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(suggestion, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    FailureType? failureType,
  ) {
    return Column(
      children: [
        // Primary Action Button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              _handlePrimaryAction(context, failureType);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _getPrimaryActionText(failureType),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Action Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {
              _handleSecondaryAction(context, failureType);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _getSecondaryActionText(failureType),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contact our support team',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // _showSupportDialog(context);
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  String _getPrimaryActionText(FailureType? failureType) {
    switch (failureType) {
      case FailureType.paymentDeclined:
      case FailureType.insufficientFunds:
      case FailureType.invalidPaymentMethod:
        return 'Try Different Payment Method';
      case FailureType.parkingUnavailable:
        return 'Browse Other Parkings';
      case FailureType.timeout:
      case FailureType.networkError:
      case FailureType.serverError:
        return 'Try Again';
      case FailureType.duplicateBooking:
        return 'View My Bookings';
      default:
        return 'Try Again';
    }
  }

  String _getSecondaryActionText(FailureType? failureType) {
    switch (failureType) {
      case FailureType.paymentDeclined:
      case FailureType.insufficientFunds:
      case FailureType.invalidPaymentMethod:
        return 'Add New Payment Method';
      case FailureType.parkingUnavailable:
        return 'Search Different Dates';
      case FailureType.duplicateBooking:
        return 'Book Different Parking';
      default:
        return 'Back to Home';
    }
  }

  void _handlePrimaryAction(BuildContext context, FailureType? failureType) {
    switch (failureType) {
      case FailureType.paymentDeclined:
      case FailureType.insufficientFunds:
      case FailureType.invalidPaymentMethod:
        // Go back to payment screen with same booking
        if (booking != null) {
          AppNavigator.goNamed(context, PaymentRoutes.payment, extra: booking);
        } else {
          // context.pop();
        }
        break;
      case FailureType.parkingUnavailable:
        // context.goNamed(AppRoutes.home); // Assuming you have home route
        break;
      case FailureType.duplicateBooking:
        // context.goNamed(AppRoutes.bookings);
        break;
      case FailureType.timeout:
      case FailureType.networkError:
      case FailureType.serverError:
        if (booking != null) {
          // context.goNamed(AppRoutes.payment, extra: booking);
        } else {
          // context.pop();
        }
        break;
      default:
      // context.pop();
    }
  }

  void _handleSecondaryAction(BuildContext context, FailureType? failureType) {
    switch (failureType) {
      case FailureType.paymentDeclined:
      case FailureType.insufficientFunds:
      case FailureType.invalidPaymentMethod:
        // Navigate to add payment method
        AppNavigator.goNamed(
          context,
          PaymentRoutes.payment,
        ); // Add payment method screen
        break;
      case FailureType.parkingUnavailable:
        // Navigate to search with different dates
        // context.pop();
        break;
      default:
      // context.go('/');
    }
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Our support team is here to help:'),
            const SizedBox(height: 16),
            _buildContactItem(Icons.email_outlined, 'support@parkshare.com'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.phone_outlined, '+1 (555) 123-4567'),
            const SizedBox(height: 12),
            _buildContactItem(Icons.chat_outlined, 'Live Chat (24/7)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(text),
      ],
    );
  }

  FailureConfig _getFailureConfig(FailureType? type) {
    switch (type) {
      case FailureType.paymentDeclined:
        return FailureConfig(
          icon: Icons.credit_card_off_rounded,
          title: 'Payment Declined',
          message:
              'Your bank declined the transaction. Please try a different payment method.',
          color: Colors.red,
        );
      case FailureType.insufficientFunds:
        return FailureConfig(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Insufficient Funds',
          message: 'Your account doesn\'t have enough funds for this booking.',
          color: Colors.orange,
        );
      case FailureType.parkingUnavailable:
        return FailureConfig(
          icon: Icons.local_parking_rounded,
          title: 'Parking Unavailable',
          message:
              'Sorry, this parking space is no longer available for your selected time.',
          color: Colors.orange,
        );
      case FailureType.timeout:
        return FailureConfig(
          icon: Icons.timer_off_rounded,
          title: 'Request Timeout',
          message: 'The request took too long to complete. Please try again.',
          color: Colors.amber,
        );
      case FailureType.networkError:
        return FailureConfig(
          icon: Icons.wifi_off_rounded,
          title: 'Network Error',
          message: 'Unable to connect. Please check your internet connection.',
          color: Colors.amber,
        );
      case FailureType.serverError:
        return FailureConfig(
          icon: Icons.error_outline_rounded,
          title: 'Server Error',
          message: 'Something went wrong on our end. Please try again later.',
          color: Colors.red,
        );
      case FailureType.duplicateBooking:
        return FailureConfig(
          icon: Icons.repeat_rounded,
          title: 'Duplicate Booking',
          message: 'You already have a booking for this time slot.',
          color: Colors.orange,
        );
      case FailureType.invalidPaymentMethod:
        return FailureConfig(
          icon: Icons.credit_card_rounded,
          title: 'Invalid Payment Method',
          message: 'The payment method you selected is invalid or expired.',
          color: Colors.red,
        );
      default:
        return FailureConfig(
          icon: Icons.error_rounded,
          title: 'Booking Failed',
          message: 'Unable to complete your booking. Please try again.',
          color: Colors.red,
        );
    }
  }
}

class FailureConfig {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  FailureConfig({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });
}
