import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/payment/widgets/order_summary.dart';
import 'package:src/modules/payment/widgets/payment_button.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/providers/payment_provider.dart';
import 'package:src/shared/widgets/custom_appbar.dart';
import 'package:src/shared/widgets/error_banner.dart';

class PaymentScreen extends ConsumerWidget {
  final ReservationModel booking;
  final String currency;

  const PaymentScreen({
    super.key,
    required this.booking,
    this.currency = 'MAD',
  });

  static const double _feeRate = 0.15;

  double get _platformFee =>
      double.parse((booking.totalPrice * _feeRate).toStringAsFixed(2));

  double get _ownerPayout =>
      double.parse((booking.totalPrice * (1 - _feeRate)).toStringAsFixed(2));

  static Future<void> show(
    BuildContext context, {
    required ReservationModel booking,
    String currency = 'MAD',
  }) async {
    AppNavigator.pushNamed(context, PaymentRoutes.payment, extra: booking);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentProvider);

    // Auto-pop once we hit a terminal state
    ref.listen(paymentProvider, (_, next) {
      if (next.isSuccess || next.isCancelled) {
        Navigator.pop(context, next.isSuccess);
      }
    });

    return Scaffold(
      appBar: CustomAppBar(title: 'Checkout', centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OrderSummary(
                amount: booking.totalPrice,
                platformFee: _platformFee,
                ownerPayout: _ownerPayout,
                currency: currency,
              ),

              const Spacer(),

              if (state.isFailed && state.errorMessage != null) ...[
                ErrorBanner(message: state.errorMessage!),
                const SizedBox(height: 16),
              ],

              PayButton(
                amount: booking.totalPrice,
                currency: currency,
                reservationId: booking.id,
                payerId: booking.driverId,
                isLoading: state.isLoading,
                hasFailed: state.isFailed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
