import 'package:flutter/material.dart';
import 'package:marketly/presentation/user/checkout/address_screen.dart';
import 'package:marketly/presentation/user/checkout/order_summary_screen.dart';
import 'package:marketly/presentation/user/checkout/payment_screen.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CheckoutFlowScreen extends StatefulWidget {
  const CheckoutFlowScreen({super.key});

  @override
  State<StatefulWidget> createState() => _checkoutFlowScreenState();
}

class _checkoutFlowScreenState extends State<CheckoutFlowScreen> {
  late CartProvider _cartProvider;

  int _currentStep = 0;

  void _goNext() {
    if (_currentStep == 0) {
      context.read<CartProvider>().lockCart();
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cartProvider = Provider.of<CartProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(
              "Cancel checkout?",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
            content: Text(
              "Your cart will be unlocked.",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "No",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          _cartProvider.unlockCart();
          Navigator.of(context).pop(result);
        }
      },

      child: Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Theme(
            data: Theme.of(context).copyWith(
              scaffoldBackgroundColor: Colors.white,

              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.black, // active step circle & line
                onPrimary: Colors.white, // number color inside active circle
                onSurface: const Color(0xFF5C5C5C), // inactive step text
              ),

              dividerColor: Colors.transparent, // removes harsh dividers
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              controlsBuilder: (_, __) => const SizedBox(),

              onStepTapped: (index) {
                if (index <= _currentStep) {
                  setState(() => _currentStep = index);
                }
              },

              steps: [
                Step(
                  title: const Text("Review"),
                  content: OrderSummaryScreen(onNext: _goNext),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text("Address"),
                  content: AddressScreen(onNext: _goNext, onBack: _goBack),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                ),
                Step(
                  title: const Text("Payment"),
                  content: PaymentScreen(onBack: _goBack),
                  isActive: _currentStep >= 2,
                  state: StepState.indexed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
