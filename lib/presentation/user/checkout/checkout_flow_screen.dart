import 'package:flutter/material.dart';
import 'package:another_stepper/another_stepper.dart';
import 'package:marketly/presentation/user/checkout/address_screen.dart';
import 'package:marketly/presentation/user/checkout/order_summary_screen.dart';
import 'package:marketly/presentation/user/checkout/payment_screen.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CheckoutFlowScreen extends StatefulWidget {
  const CheckoutFlowScreen({super.key});

  @override
  State<CheckoutFlowScreen> createState() => _CheckoutFlowScreenState();
}

class _CheckoutFlowScreenState extends State<CheckoutFlowScreen> {
  late CartProvider _cartProvider;

  int _currentStep = 0;

  void _goNext() {
    if (_currentStep == 0) {
      _cartProvider.lockCart();
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

  Future<void> _confirmCancelCheckout({Object? result}) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      _cartProvider.unlockCart();
      Navigator.of(context).pop(result);
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
        if (didPop) return;
        await _confirmCancelCheckout(result: result);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              AnotherStepper(
                stepperDirection: Axis.horizontal,
                activeIndex: _currentStep,
                barThickness: 5,
                activeBarColor: Theme.of(context).colorScheme.onSecondary,
                inActiveBarColor: Theme.of(
                  context,
                ).colorScheme.onInverseSurface,
                iconWidth: 36,
                iconHeight: 36,

                stepperList: [
                  _step("Review", 0),
                  _step("Address", 1),
                  _step("Payment", 2),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    OrderSummaryScreen(
                      onNext: _goNext,
                      onCancel: _confirmCancelCheckout,
                    ),
                    AddressScreen(onNext: _goNext, onBack: _goBack),
                    PaymentScreen(onBack: _goBack),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  StepperData _step(String title, int index) {
    final isCompleted = _currentStep > index;
    final isActive = _currentStep == index;

    return StepperData(
      title: StepperText(
        title,
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: isActive || isCompleted
              ? FontWeight.w600
              : FontWeight.w400,
          color: isActive || isCompleted
              ? Theme.of(context).colorScheme.onSecondary
              : Theme.of(context).colorScheme.onInverseSurface,
        ),
      ),
      iconWidget: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted || isActive
              ? Theme.of(context).colorScheme.onSecondary
              : Theme.of(context).colorScheme.onInverseSurface,
        ),
        child: Center(
          child: isCompleted
              ? Icon(
                  Icons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                )
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
        ),
      ),
    );
  }
}
