import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:src/providers/booking_time_provider.dart';

class TimeSelectionBar extends ConsumerWidget {
  const TimeSelectionBar({super.key});

  Future<void> _pickDateAndTime(
    BuildContext context, 
    DateTime initialTime,
    void Function(DateTime) onSelected,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    if (!context.mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );
    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onSelected(selected);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingTime = ref.watch(bookingTimeProvider);
    final notifier = ref.read(bookingTimeProvider.notifier);

    final dateFormatter = DateFormat('EEE, MMM d').format;
    final timeFormatter = DateFormat('h:mm a').format;

    return Container(
      color: const Color(0xFF3B5668), // Matches the dark blueish theme from screenshot
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Arrive Column
          Expanded(
            child: GestureDetector(
              onTap: () => _pickDateAndTime(context, bookingTime.arriveTime, notifier.updateArriveTime),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARRIVE AFTER',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dateFormatter(bookingTime.arriveTime).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('|', style: TextStyle(color: Colors.white54)),
                      ),
                      Text(
                        timeFormatter(bookingTime.arriveTime),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, color: Colors.white, size: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Arrow right
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, color: Colors.white, size: 16),
          ),
          
          // Exit Column
          Expanded(
            child: GestureDetector(
              onTap: () => _pickDateAndTime(context, bookingTime.exitTime, notifier.updateExitTime),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXIT BEFORE',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        dateFormatter(bookingTime.exitTime).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('|', style: TextStyle(color: Colors.white54)),
                      ),
                      Text(
                        timeFormatter(bookingTime.exitTime),
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, color: Colors.white, size: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
