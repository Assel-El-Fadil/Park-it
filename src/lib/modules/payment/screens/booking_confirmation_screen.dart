import 'package:flutter/material.dart';
import 'package:src/modules/payment/models/payment_model.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final ParkingBooking? booking;

  const BookingConfirmationScreen({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                booking != null
                    ? 'Your parking at ${booking!.parkingName} is confirmed'
                    : 'Your booking has been confirmed',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // context.goNamed(AppRoutes.bookings);
                  },
                  child: const Text('View My Bookings'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // context.go('/'); // Go to home
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
