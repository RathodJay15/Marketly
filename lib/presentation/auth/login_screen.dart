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

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _emailError;
  String? _passError;
  String? _errorMsg;
  bool isLoading = false;
  bool hiddenPass = true;

  void _showPass() {
    setState(() {
      hiddenPass = !hiddenPass;
    });
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      _emailError = null;
      _passError = null;
      _errorMsg = null;
    });
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Please enter email!';
      });
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passError = 'Please enter password!';
      });
      return;
    }

    try {
      final user = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        context.read<UserProvider>().setUser(user);
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
                  TextField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    textInputAction: TextInputAction.next,
                    controller: _emailController,
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
                  _emailError != null
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: Align(
                            alignment:
                                Alignment.centerLeft, // aligns text to the left
                            child: Text(
                              _emailError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 20.0),

                  // Password Text Field
                  TextField(
                    obscureText: hiddenPass,
                    controller: _passwordController,
                    onSubmitted: (value) => _login(),
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
                        icon: Icon(
                          hiddenPass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                  _passError != null
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 6,
                            bottom: 18,
                            left: 6,
                          ),
                          child: Align(
                            alignment:
                                Alignment.centerLeft, // aligns text to the left
                            child: Text(
                              _passError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 40.0),

                  // Sign In Button
                  ElevatedButton(
                    onPressed: () => _login(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onInverseSurface,
                      minimumSize: const Size(double.infinity, 50.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'SIGN IN',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
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
    );
  }
}
