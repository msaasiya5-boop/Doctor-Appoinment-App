import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  final Razorpay _razorpay = Razorpay();

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onWallet,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  void openPayment({
    required int amount,
    required String name,
    required String description,
  }) {
    var options = {
      "key": "YOUR_RAZORPAY_TEST_KEY",
      "amount": amount * 100,
      "name": name,
      "description": description,
      "prefill": {
        "contact": "9999999999",
        "email": "test@test.com",
      }
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
