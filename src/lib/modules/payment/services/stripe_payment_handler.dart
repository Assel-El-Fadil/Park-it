abstract class StripePaymentHandler {
  Future<void> present(String clientSecret);
}
