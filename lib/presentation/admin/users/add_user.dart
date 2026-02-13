import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/providers/admin/admin_user_provider.dart';
import 'package:provider/provider.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<StatefulWidget> createState() => _addUserState();
}

class _addUserState extends State<AddUser> {
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

  final _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      _errorMsg = null;
    });

    try {
      await _authService.register(
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

      /// After registration
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppConstants.userCreated,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      await context.read<AdminUserProvider>().fetchAllUsers();
      Navigator.pop(context, true);
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppConstants.addProduct,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _detailsForm(),
    );
  }

  Widget _detailsForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _label(AppConstants.username),
          _field(
            _usernameController,
            AppConstants.username,
            Validators.username,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.email),
          _field(
            _emailController,
            AppConstants.email,
            Validators.email,
            keyboardType: TextInputType.emailAddress,
          ),

          _label(AppConstants.pass),
          _field(
            _passwordController,
            AppConstants.pass,
            Validators.password,
            obscureText: _obscurePassword,
            onToggleVisibility: _showPass,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.confPass),
          _field(
            _confirmController,
            AppConstants.confPass,
            (value) =>
                Validators.confirmPassword(value, _passwordController.text),
            keyboardType: TextInputType.text,
            obscureText: _obscureConfirm,
            onToggleVisibility: _showConf,
          ),

          _label(AppConstants.phone),
          _field(
            _phoneController,
            AppConstants.phone,
            Validators.phone,
            keyboardType: TextInputType.number,
          ),
          _label(AppConstants.adrs),
          _field(
            _addressController,
            AppConstants.adrs,
            Validators.address,
            keyboardType: TextInputType.text,
            maxLine: 3,
          ),

          _label(AppConstants.ct),
          _field(
            _cityController,
            AppConstants.ct,
            Validators.city,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.state),
          _field(
            _stateController,
            AppConstants.state,
            Validators.state,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.cntry),
          _field(
            _countyController,
            AppConstants.cntry,
            Validators.country,
            keyboardType: TextInputType.text,
          ),

          _label(AppConstants.pincode),
          _field(
            _pincodeController,
            AppConstants.pincode,
            Validators.pincode,
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _register,
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
                      AppConstants.register,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    String? Function(String?)? validator, {
    TextInputType? keyboardType,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    maxLine = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        keyboardType: keyboardType,
        obscureText: obscureText,
        minLines: 1,
        maxLines: maxLine,
        textInputAction: hint == AppConstants.depth
            ? TextInputAction.done
            : TextInputAction.next,
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
        validator: validator,
      ),
    );
  }
}
