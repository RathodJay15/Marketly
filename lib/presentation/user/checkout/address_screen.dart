import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/data/models/user_model.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  const AddressScreen({super.key, required this.onBack, required this.onNext});

  @override
  State<StatefulWidget> createState() => _addressScreenState();
}

class _addressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();

  String? selectedAddressId;
  bool _initialized = false;

  void _initFromUser(UserModel user) {
    if (_initialized) return;

    nameCtrl.text = user.name;
    emailCtrl.text = user.email;
    phoneCtrl.text = user.phone;
    cityCtrl.text = user.city;
    stateCtrl.text = user.state;
    countryCtrl.text = user.country;
    pincodeCtrl.text = user.pincode;

    if (user.addresses.isNotEmpty) {
      final defaultAddr = user.addresses.firstWhere(
        (a) => a.isDefault == true,
        orElse: () => user.addresses.first,
      );

      selectedAddressId = defaultAddr.id;
      addressCtrl.text = defaultAddr.address;
    }

    _initialized = true;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    countryCtrl.dispose();
    pincodeCtrl.dispose();
    super.dispose();
  }

  void _saveAddressDetails() {
    final orderProvider = context.read<OrderProvider>();

    if (!_formKey.currentState!.validate()) return;

    final addressData = {
      "addressId": selectedAddressId,
      "name": nameCtrl.text.trim(),
      "email": emailCtrl.text.trim(),
      "phone": phoneCtrl.text.trim(),
      "address": addressCtrl.text.trim(),
      "city": cityCtrl.text.trim(),
      "state": stateCtrl.text.trim(),
      "country": countryCtrl.text.trim(),
      "pincode": pincodeCtrl.text.trim(),
    };

    orderProvider.setAddress(addressData);

    FocusManager.instance.primaryFocus?.unfocus();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _detailsForm()),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: widget.onBack,
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
                    AppConstants.back,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    // FocusManager.instance.primaryFocus?.unfocus();
                    // widget.onNext();
                    if (_formKey.currentState!.validate()) {
                      _saveAddressDetails();
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
                  child: Text(
                    AppConstants.next,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailsForm() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        _initFromUser(user);

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 12),

              _field(
                nameCtrl,
                AppConstants.username,
                Validators.username,
                icon: Icons.person_outline,
              ),

              _field(
                emailCtrl,
                AppConstants.email,
                Validators.email,
                icon: Icons.email_outlined,
                readOnly: true,
              ),

              _field(
                phoneCtrl,
                AppConstants.phone,
                Validators.phone,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedAddressId,
                dropdownColor: Theme.of(context).colorScheme.onPrimary,
                hint: Text(
                  AppConstants.selectAdrs,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
                items: user.addresses.map((addr) {
                  return DropdownMenuItem<String>(
                    value: addr.id,
                    child: Text(
                      addr.address,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  final selected = user.addresses.firstWhere(
                    (a) => a.id == value,
                  );
                  setState(() {
                    selectedAddressId = value;
                    addressCtrl.text = selected.address;
                  });
                },
                validator: (value) =>
                    value == null ? AppConstants.selectAdrs : null,
              ),

              const SizedBox(height: 12),

              _field(
                cityCtrl,
                AppConstants.ct,
                Validators.city,
                icon: Icons.location_city_outlined,
              ),

              _field(
                stateCtrl,
                AppConstants.state,
                Validators.state,
                icon: Icons.map_outlined,
              ),

              _field(
                countryCtrl,
                AppConstants.cntry,
                Validators.country,
                icon: Icons.public_outlined,
              ),

              _field(
                pincodeCtrl,
                AppConstants.pincode,
                Validators.pincode,
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    String? Function(String?)? validator, {
    IconData icon = Icons.text_fields_outlined,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: 1,
        textInputAction: TextInputAction.done,
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
        ),
        validator: validator,
      ),
    );
  }
}
