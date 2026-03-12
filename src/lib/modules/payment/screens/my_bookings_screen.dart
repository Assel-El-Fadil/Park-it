import 'package:flutter/material.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: ListView.builder(
        itemCount: 5, // Replace with actual bookings
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.local_parking),
            title: Text('Downtown Parking #${index + 1}'),
            subtitle: Text('March ${15 + index}, 2026'),
            trailing: Chip(
              label: Text(
                index % 2 == 0 ? 'Confirmed' : 'Completed',
                style: TextStyle(
                  color: index % 2 == 0 ? Colors.green : Colors.grey,
                ),
              ),
            ),
            onTap: () {
              // Navigate to booking details with ID
              // context.goNamed(
              //   AppRoutes.bookingDetails,
              //   pathParameters: {'id': 'booking_${index + 1}'},
              //   extra: null, // You can pass booking object here
              // );
            },
          );
        },
      ),
    );
  }
}
