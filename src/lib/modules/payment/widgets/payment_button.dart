import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/navigation/models/spot_model.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/reservation/repositories/reservation_repository.dart';
import 'package:src/providers/payment_provider.dart';
import 'package:src/shared/widgets/custom_modal.dart';

class PayButton extends ConsumerStatefulWidget {
  final double amount;
  final String currency;
  final int reservationId;
  final String payerId;
  final bool isLoading;
  final bool hasFailed;

  const PayButton({
    super.key,
    required this.amount,
    required this.currency,
    required this.reservationId,
    required this.payerId,
    required this.isLoading,
    required this.hasFailed,
  });

  @override
  ConsumerState<PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends ConsumerState<PayButton> {
  PaymentMethod _method = PaymentMethod.card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Method selector
        Wrap(
          spacing: 8,
          children: PaymentMethod.values.map((m) {
            return ChoiceChip(
              label: Text(_methodLabel(m)),
              selected: m == _method,
              onSelected: (_) => setState(() => _method = m),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        FilledButton(
          onPressed: widget.isLoading ? null : _handlePay,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.hasFailed
                      ? 'Try again — ${widget.amount.toStringAsFixed(2)} ${widget.currency}'
                      : 'Pay ${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ],
    );
  }

  Future<void> _handlePay() async {
    final router = GoRouter.of(context);
    final reservationRepo = ref.read(reservationRepositoryProvider);

    final result = await ref
        .read(paymentProvider.notifier)
        .processPayment(
          reservationId: widget.reservationId,
          payerId: widget.payerId,
          amount: widget.amount,
          method: _method,
          currency: widget.currency,
        );

    if (!mounted) return;

    if (result) {
      CustomModal.show(
        context: context,
        message: "Do you want to go there now?",
        confirmText: "Yes",
        onConfirm: () async {
          final value = await reservationRepo.getReservationWithDetails(
            widget.reservationId,
          );

          final spot = value['parking_spots'] as Map<String, dynamic>;

          router.pushNamed(
            NavigationRoutes.navigation,
            extra: SpotModel(
              id: (spot['id'] as int).toString(),
              name: spot['title'] as String,
              latitude: (spot['latitude'] as num).toDouble(),
              longitude: (spot['longitude'] as num).toDouble(),
            ),
          );
        },
      );
    }
  }

  String _methodLabel(PaymentMethod m) => switch (m) {
    PaymentMethod.card => 'Card',
    PaymentMethod.applePay => 'Apple Pay',
    PaymentMethod.googlePay => 'Google Pay',
  };
}
