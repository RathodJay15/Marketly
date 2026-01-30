import 'package:flutter/material.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/presentation/auth/login_screen.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _registerScreenState();
}

class _registerScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final _authService = authService;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool isLoading = false;
  String? _unameError;
  String? _emailError;
  String? _passError;
  String? _confError;
  String? _phoneError;
  String? _addressError;
  String? _errorMsg;

  void _showPass() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showConf() {
    setState(() {
      _obscureConfirm = !_obscureConfirm;
    });
  }

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      _errorMsg = null;
      _unameError = null;
      _emailError = null;
      _passError = null;
      _addressError = null;
      _confError = null;
      _phoneError = null;
    });

    if (_usernameController.text.isEmpty) {
      setState(() {
        _unameError = 'Please enter username!';
      });
      return;
    }
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
    if (_confirmController.text.isEmpty) {
      setState(() {
        _confError = 'Please confirm password!';
      });
      return;
    }
    if (_confirmController.text != _passwordController.text) {
      setState(() {
        _confError = 'Paasword dose not match!';
      });
      return;
    }
    if (_phoneController.text.isEmpty) {
      setState(() {
        _phoneError = 'Please enter phone number!';
      });
      return;
    }
    if (_addressController.text.isEmpty) {
      setState(() {
        _addressError = 'Please enter address!';
      });
      return;
    }

    try {
      final user = await _authService.register(
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        profilePic: '',
      );

      if (user != null) {
        context.read<UserProvider>().setUser(user);
        Navigator.pop(context);
        // authStateChanges → HomeScreen
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
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
                    Icons.app_registration_outlined,
                    size: 80.0,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  SizedBox(height: 30.0),

                  Text(
                    'Get started with Marketly',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Subtitle
                  Text(
                    'Sign up to continue',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  // Username Text Field
                  TextField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
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
                        Icons.person_rounded,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                  _unameError != null
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: Align(
                            alignment:
                                Alignment.centerLeft, // aligns text to the left
                            child: Text(
                              _unameError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 20.0),

                  // Email Text Field
                  TextField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
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
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
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
                          _obscurePassword
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
                          padding: const EdgeInsets.only(top: 6),
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
                      : const SizedBox(height: 20.0),

                  //Confirm Password Text Field
                  TextField(
                    obscureText: _obscureConfirm,
                    controller: _confirmController,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
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
                        onPressed: () => _showConf(),
                        icon: Icon(
                          _obscureConfirm
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
                  _confError != null
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: Align(
                            alignment:
                                Alignment.centerLeft, // aligns text to the left
                            child: Text(
                              _confError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 20.0),

                  // Phone Text Field
                  TextField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    textInputAction: TextInputAction.next,
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Phone',
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
                        Icons.phone,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                  _phoneError != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Align(
                            alignment:
                                Alignment.centerLeft, // aligns text to the left
                            child: Text(
                              _phoneError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 20.0),

                  // Address Text Field
                  TextField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    textInputAction: TextInputAction.done,
                    minLines: 1,
                    maxLines: 3,
                    controller: _addressController,
                    onSubmitted: (value) => _register(),
                    decoration: InputDecoration(
                      hintText: 'Address',
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
                        Icons.home,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                  _addressError != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Align(
                            alignment:
                                Alignment.centerLeft, // aligns text to the left
                            child: Text(
                              _addressError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 40.0),

                  // Sign up Button
                  ElevatedButton(
                    onPressed: () => _register(),
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
                      'SIGN UP',
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
                      padding: const EdgeInsets.all(5),
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
                        "Already have an Account!",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Login",
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
