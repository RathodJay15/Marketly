import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';

class ForgotpassScreen extends StatefulWidget {
  const ForgotpassScreen({super.key});

  @override
  State<StatefulWidget> createState() => _forgotpassScreenState();
}

class _forgotpassScreenState extends State<ForgotpassScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  bool isLoading = false;

  void changePass(String email) async {
    final confirm = await MarketlyDialog.showMyDialog(
      context: context,
      title: AppConstants.changePass,
      content: AppConstants.checkForMail,
      actionN: AppConstants.cancel,
      actionY: AppConstants.yes,
    );
    if (confirm == true) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      try {
        await auth.sendPasswordResetEmail(email: email.trim());
        return null; // success
      } on FirebaseAuthException catch (e) {
        debugPrint("Change Pass Error : ${e.message}");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            content: Text(
              AppConstants.errorInChangePass,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        );
      }
    }
  }

  Future<void> _onSend() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      changePass(_emailController.text.trim());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: SizedBox(
              width: 500,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppConstants.forgotPass,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // Email Text Field
                    TextFormField(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                      textInputAction: TextInputAction.next,
                      controller: _emailController,
                      validator: (value) => Validators.email(value),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: AppConstants.email,
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: SizedBox(
                          height: 40,
                          width: 40,
                          child: Center(
                            child: Iconoir(
                              IconoirIcons.mail,
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    const SizedBox(height: 20),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: () {
                        if (isLoading) return;

                        if (_formKey.currentState!.validate()) {
                          _onSend();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onInverseSurface,
                        minimumSize: const Size(double.infinity, 50.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : Text(
                              AppConstants.send,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppConstants.goTo,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppConstants.login,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
