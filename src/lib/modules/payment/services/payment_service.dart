// import 'package:src/modules/payment/models/payment_model.dart';

// class PaymentService {
//   Future<void> processPayment(
//     ParkingBooking booking,
//     PaymentMethod method,
//   ) async {
//     try {
//       // Simulate payment processing
//       await Future.delayed(const Duration(seconds: 2));

//       // Randomly fail for demo purposes
//       final random = DateTime.now().second % 3;

//       if (random == 0) {
//         throw PaymentDeclinedException(
//           message: 'Your bank declined the transaction',
//           code: 'DECLINE_001',
//         );
//       } else if (random == 1) {
//         throw InsufficientFundsException();
//       } else if (random == 2) {
//         throw NetworkException();
//       }
//     } on PaymentDeclinedException {
//       rethrow;
//     } on InsufficientFundsException {
//       rethrow;
//     } on NetworkException {
//       rethrow;
//     } catch (e) {
//       throw ServerException();
//     }
//   }
// }

// // Custom exceptions
// class PaymentDeclinedException implements Exception {
//   final String message;
//   final String code;
//   PaymentDeclinedException({required this.message, required this.code});
// }

// class InsufficientFundsException implements Exception {}

// class NetworkException implements Exception {}

// class ServerException implements Exception {}
