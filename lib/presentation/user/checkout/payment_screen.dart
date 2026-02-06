import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final VoidCallback onBack;
  const PaymentScreen({super.key, required this.onBack});

  @override
  State<StatefulWidget> createState() => _paymentScreenState();
}

class _paymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: widget.onBack,
                child: const Text("Back"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
