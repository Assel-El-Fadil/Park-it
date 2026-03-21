import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingTimeState {
  final DateTime arriveTime;
  final DateTime exitTime;

  BookingTimeState({required this.arriveTime, required this.exitTime});

  int get durationHours {
    final diff = exitTime.difference(arriveTime).inHours;
    return diff > 0 ? diff : 1;
  }
}

class BookingTimeNotifier extends Notifier<BookingTimeState> {
  @override
  BookingTimeState build() {
    final now = DateTime.now();
    // Default arrive: Next full hour
    final arrive = DateTime(now.year, now.month, now.day, now.hour + 1);
    final exit = arrive.add(const Duration(hours: 2));
    return BookingTimeState(arriveTime: arrive, exitTime: exit);
  }

  void updateArriveTime(DateTime newArrive) {
    DateTime newExit = state.exitTime;
    if (newExit.isBefore(newArrive) || newExit.difference(newArrive).inHours < 1) {
      newExit = newArrive.add(const Duration(hours: 1));
    }
    state = BookingTimeState(arriveTime: newArrive, exitTime: newExit);
  }

  void updateExitTime(DateTime newExit) {
    DateTime newArrive = state.arriveTime;
    if (newExit.isBefore(newArrive) || newExit.difference(newArrive).inHours < 1) {
      newArrive = newExit.subtract(const Duration(hours: 1));
    }
    state = BookingTimeState(arriveTime: newArrive, exitTime: newExit);
  }
}

final bookingTimeProvider = NotifierProvider<BookingTimeNotifier, BookingTimeState>(() {
  return BookingTimeNotifier();
});
