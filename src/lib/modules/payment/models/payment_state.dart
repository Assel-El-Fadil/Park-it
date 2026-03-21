import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/payment/models/payment_model.dart';

class PaymentState {
  final PaymentStatus status;
  final PaymentModel? payment;
  final String? errorMessage;
  final bool isRefunding;

  const PaymentState({
    this.status = PaymentStatus.idle,
    this.payment,
    this.errorMessage,
    this.isRefunding = false,
  });

  bool get isLoading => status == PaymentStatus.loading;
  bool get isSuccess => status == PaymentStatus.succeeded;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentModel? payment,
    String? errorMessage,
    bool? isRefunding,
    bool clearError = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      payment: payment ?? this.payment,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isRefunding: isRefunding ?? this.isRefunding,
    );
  }
}
