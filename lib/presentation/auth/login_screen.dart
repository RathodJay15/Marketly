import 'package:flutter/material.dart';
import 'package:marketly/presentation/auth/register_screen.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _loginScreenState();
}

class _loginScreenState extends State<LoginScreen> {
  final _authService = authService;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _errorMsg;
  bool isLoading = false;
  bool hiddenPass = true;

  void _showPass() {
    setState(() {
      hiddenPass = !hiddenPass;
    });
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      isLoading = true;
      _errorMsg = null;
    });

    try {
      final user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        context.read<UserProvider>().setUser(user);
        _emailController.clear();
        _passwordController.clear();
        // navigation handled by authStateChanges
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                    Icon(
                      Icons.person_search,
                      size: 80.0,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    SizedBox(height: 30.0),

                    Text(
                      'Welcome to Marketly',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    // Subtitle
                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16.0,
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
                        hintText: 'Email',
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
                        prefixIcon: Icon(
                          Icons.email,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Password Text Field
                    TextFormField(
                      obscureText: hiddenPass,
                      controller: _passwordController,
                      validator: (value) => Validators.loginPassword(value),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Password',
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
                        suffixIcon: IconButton(
                          onPressed: () => _showPass(),
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          icon: Icon(
                            hiddenPass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),

                    // Sign In Button
                    ElevatedButton(
                      onPressed: () {
                        if (isLoading) return;

                        if (_formKey.currentState!.validate()) {
                          _login();
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
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10.0),
                    if (_errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Align(
                          child: Text(
                            _errorMsg!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an Account!",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _formKey.currentState?.reset();
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Register now",
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

class Validators {
  //  Email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // Password
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password is too short';
    }

    return null;
  }
}
