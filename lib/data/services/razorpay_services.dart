import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayServices {
  late Razorpay _razorpay;

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailur,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailur);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openCheckOut({
    required double amount,
    required String name,
    required String email,
    required String phoneNo,
    required String description,
  }) {
    var options = {
      'key': 'rzp_test_SNq2skq6gT54PO',
      'amount': (amount * 100).toInt(),
      'name': name,
      'description': description,
      'prefill': {'contact': phoneNo, 'email': email},
      'method': {'upi': true},
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
