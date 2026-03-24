import 'package:flutter/material.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/payment/screens/payment_screen.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class PaymentTestWidget extends StatelessWidget {
  const PaymentTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Payment Test'),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final reservation = ReservationModel(
              id: 11,
              driverId: "6",
              spotId: 7,
              vehicleId: 8,
              startTime: DateTime.now(),
              endTime: DateTime.now().add(const Duration(hours: 2)),
              status: ReservationStatus.pending,
              totalPrice: 40.0,
              platformFee: 5.0,
              lockExpiresAt: DateTime.now().add(const Duration(minutes: 10)),
              cancellationReason: null,
              accessCode: "TEST123",
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            PaymentScreen.show(context, booking: reservation, currency: 'MAD');
          },
          child: const Text("Open Payment Screen"),
        ),
      ),
    );
  }
}
