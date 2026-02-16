import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/data/models/user_model.dart';
import 'package:marketly/data/services/image_service.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countyController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final ImageService _profilePicService = ImageService();

  final _authService = authService;

  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool isLoading = false;
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

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      // backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  size: 30,
                ),
                title: Text(
                  AppConstants.camera,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 23,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  size: 30,
                ),
                title: Text(
                  AppConstants.gallery,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 23,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      _errorMsg = null;
    });

    try {
      final user = await _authService.register(
        name: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countyController.text.trim(),
        pincode: _pincodeController.text.trim(),
        profilePic: '',
      );
      if (user != null) {
        if (_selectedImage != null) {
          final imageUrl = await _profilePicService.uploadProfileImage(
            uid: user.uid,
            imageFile: _selectedImage!,
          );

          if (imageUrl != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'profilePic': imageUrl});
          }
        }

        if (!mounted) return;
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
    _confirmController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countyController.dispose();
    _pincodeController.dispose();
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
                      Icons.app_registration_outlined,
                      size: 80.0,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    SizedBox(height: 30.0),

                    Text(
                      AppConstants.getStartedMsg,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    // Subtitle
                    Text(
                      AppConstants.signUpToContinue,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 40.0),

                    // Username
                    _textFormField(
                      icon: Icons.person,
                      hint: AppConstants.username,
                      controller: _usernameController,
                      validator: Validators.username,
                    ),
                    const SizedBox(height: 20.0),

                    // Email
                    _textFormField(
                      icon: Icons.email_rounded,
                      hint: AppConstants.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),

                    const SizedBox(height: 20.0),

                    _textFormField(
                      icon: Icons.lock,
                      hint: AppConstants.pass,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: Validators.password,
                      onToggleVisibility: _showPass,
                    ),

                    const SizedBox(height: 20.0),
                    _textFormField(
                      icon: Icons.lock,
                      hint: AppConstants.confPass,
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      onToggleVisibility: _showConf,
                    ),

                    const SizedBox(height: 20.0),
                    _textFormField(
                      icon: Icons.phone,
                      hint: AppConstants.phone,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                    ),

                    const SizedBox(height: 20.0),
                    _textFormField(
                      icon: Icons.home_rounded,
                      hint: AppConstants.adrs,
                      controller: _addressController,
                      validator: Validators.address,
                      maxLine: 3,
                    ),
                    const SizedBox(height: 20.0),
                    _textFormField(
                      icon: Icons.location_city_outlined,
                      hint: AppConstants.ct,
                      controller: _cityController,
                      validator: Validators.username,
                    ),
                    const SizedBox(height: 20.0),
                    _textFormField(
                      icon: Icons.map_outlined,
                      hint: AppConstants.state,
                      controller: _stateController,
                      validator: Validators.username,
                    ),
                    const SizedBox(height: 20.0),
                    _textFormField(
                      icon: Icons.public_outlined,
                      hint: AppConstants.cntry,
                      controller: _countyController,
                      validator: Validators.username,
                    ),

                    const SizedBox(height: 20.0),
                    _textFormField(
                      icon: Icons.pin_outlined,
                      hint: AppConstants.pincode,
                      controller: _pincodeController,
                      validator: Validators.username,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20.0),
                    _profileImageFormField(
                      imageFile: _selectedImage,
                      onTap: _pickImage,
                    ),

                    const SizedBox(height: 40.0),

                    // Sign up Button
                    ElevatedButton(
                      onPressed: () {
                        if (isLoading) return;

                        if (_formKey.currentState!.validate()) {
                          _register();
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
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : Text(
                              AppConstants.signup,
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
                          AppConstants.haveAnAccount,
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

  Widget _textFormField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    int maxLine = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLine,
      minLines: 1,
      textInputAction: TextInputAction.next,
      style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
        suffixIcon: onToggleVisibility != null
            ? IconButton(
                onPressed: onToggleVisibility,
                color: Theme.of(context).colorScheme.onInverseSurface,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              )
            : null,
      ),
    );
  }

  Widget _profileImageFormField({
    required File? imageFile,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // left icon
            Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),

            const SizedBox(width: 12),

            // text / preview
            Expanded(
              child: imageFile == null
                  ? Text(
                      AppConstants.upldProfilePic,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: FileImage(imageFile),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppConstants.imgSelected,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
            ),

            Icon(
              Icons.camera_alt_outlined,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
