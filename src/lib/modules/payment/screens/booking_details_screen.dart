import 'package:flutter/material.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';

class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  final ReservationModel? booking;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ID: $bookingId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            //get parking name and location from reservation module
            if (booking != null) ...[
              _buildDetailRow('Parking', "Parking Name"),
              _buildDetailRow('Location', "Parking Location"),
              _buildDetailRow(
                'Date',
                '${booking!.startTime.toLocal()}'.split(' ')[0],
              ),
              _buildDetailRow(
                'Time',
                '${booking!.startTime.hour}:00 - ${booking!.endTime.hour}:00',
              ),
              _buildDetailRow(
                'Total',
                '\$${booking!.totalPrice.toStringAsFixed(2)}',
              ),
            ],
            const Spacer(),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ParkingNavigationScreen(
            //           booking: booking,
            //           parkingLocation: booking.coordinates,
            //         ),
            //       ),
            //     );
            //   },
            //   icon: const Icon(Icons.directions_car_rounded),
            //   label: const Text('Navigate to Parking'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.green,
            //     foregroundColor: Colors.white,
            //     minimumSize: const Size(double.infinity, 50),
            //   ),
            // ),
            ElevatedButton(onPressed: () => {}, child: const Text('Back')),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
