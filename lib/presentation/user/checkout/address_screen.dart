import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const AddressScreen({super.key, required this.onBack, required this.onNext});

  @override
  State<StatefulWidget> createState() => _addressScreenState();
}

class _addressScreenState extends State<AddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: widget.onBack,
                child: const Text("Back"),
              ),
            ),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: widget.onNext,
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
