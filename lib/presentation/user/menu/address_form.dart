import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/data/models/address_model.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AddressForm extends StatefulWidget {
  String title;
  AddressModel? address;

  AddressForm({super.key, required this.title, required this.address});

  @override
  State<StatefulWidget> createState() => _addressFormState();
}

enum LocationType { country, state, city }

class _addressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  bool isDefault = false;

  TextEditingController labelController = TextEditingController();
  TextEditingController adrsController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  void onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();

    final newAddress = AddressModel(
      id:
          widget.address?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      label: labelController.text.trim(),
      address: adrsController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: countryController.text.trim(),
      pincode: pincodeController.text.trim(),
      recipientName: nameController.text.trim(),
      recipientPhone: phoneController.text.trim(),
      isDefault: isDefault,
    );

    try {
      if (widget.address != null) {
        await userProvider.updateAddress(newAddress);

        if (isDefault) {
          await userProvider.setDefaultAddress(newAddress.id);
        }
      } else {
        await userProvider.addAddress(newAddress);

        if (isDefault) {
          await userProvider.setDefaultAddress(newAddress.id);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppConstants.adrsSved,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.somthingWentWrong),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }
  }

  @override
  void initState() {
    final provider = context.read<UserProvider>();
    provider.clearLocation();

    if (widget.address != null) {
      labelController = TextEditingController(text: widget.address!.label);
      adrsController = TextEditingController(text: widget.address!.address);
      nameController = TextEditingController(
        text: widget.address!.recipientName,
      );
      phoneController = TextEditingController(
        text: widget.address!.recipientPhone,
      );
      cityController = TextEditingController(text: widget.address!.city);
      stateController = TextEditingController(text: widget.address!.state);
      countryController = TextEditingController(text: widget.address!.country);
      pincodeController = TextEditingController(text: widget.address!.pincode);
      isDefault = widget.address!.isDefault;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.selectCountry(widget.address!.country);
        provider.selectState(widget.address!.state);
        provider.selectCity(widget.address!.city);
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    labelController.dispose();
    adrsController.dispose();
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: _titleSection(),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_addressForm(), _saveButton()],
          ),
        ),
      ),
    );
  }

  Widget _titleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Iconoir(
            IconoirIcons.navArrowLeft,
            color: Theme.of(context).colorScheme.onInverseSurface,
            size: 35,
          ),
        ),
        Text(
          widget.title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _addressForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _titlePart(AppConstants.adrsLabel),
            _field(
              labelController,
              AppConstants.adrsLabel,
              Validators.requiredField,
            ),
            _titlePart(AppConstants.adrs),

            _field(adrsController, AppConstants.adrs, Validators.address),
            _titlePart(AppConstants.recipientsName),

            _field(
              nameController,
              AppConstants.recipientsName,
              Validators.username,
            ),
            _titlePart(AppConstants.recipientsPhone),

            _field(
              phoneController,
              AppConstants.recipientsPhone,
              Validators.phone,
            ),

            _titlePart(AppConstants.cntry),
            _locationDropdown(type: LocationType.country),

            _titlePart(AppConstants.state),
            _locationDropdown(type: LocationType.state),

            _titlePart(AppConstants.ct),
            _locationDropdown(type: LocationType.city),
            _titlePart(AppConstants.pincode),

            _field(pincodeController, AppConstants.pincode, Validators.pincode),

            Row(
              children: [
                Checkbox(
                  value: isDefault,
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.onInverseSurface;
                    }
                    return Theme.of(context).colorScheme.onSecondaryContainer;
                  }),
                  checkColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    width: 1.5,
                  ),

                  onChanged: widget.address?.isDefault == true
                      ? null
                      : (value) {
                          setState(() {
                            isDefault = value ?? false;
                          });
                        },
                ),
                Text(
                  AppConstants.setAsDefaultAdrs,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    String? Function(String?)? validator,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        textInputAction: TextInputAction.next,
        maxLines: hint == AppConstants.adrs ? 3 : 1,
        keyboardType:
            hint == AppConstants.recipientsPhone || hint == AppConstants.pincode
            ? TextInputType.number
            : TextInputType.text,
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
          errorStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
              width: 1,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _titlePart(String text) {
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

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            minimumSize: const Size(double.infinity, 50.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            AppConstants.save,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationDropdown({required LocationType type}) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        List<String> items = [];
        String? value;
        String hint = "";

        // Decide behavior based on type
        switch (type) {
          case LocationType.country:
            items = provider.countries;
            value = provider.selectedCountry;
            hint = AppConstants.cntry;
            break;

          case LocationType.state:
            items = provider.states;
            value = provider.selectedState;
            hint = AppConstants.state;
            break;

          case LocationType.city:
            items = provider.cities;
            value = provider.selectedCity;
            hint = AppConstants.ct;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: items.contains(value) ? value : null,
            validator: (val) => val == null ? "Required" : null,

            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),

            dropdownColor: Theme.of(context).colorScheme.onSecondaryContainer,

            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 16,
            ),

            hint: Text(
              hint,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),

            items: items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),

            onChanged: (val) {
              if (val == null) return;

              switch (type) {
                case LocationType.country:
                  provider.selectCountry(val);
                  countryController.text = val;
                  break;

                case LocationType.state:
                  provider.selectState(val);
                  stateController.text = val;
                  break;

                case LocationType.city:
                  provider.selectCity(val);
                  cityController.text = val;
                  break;
              }
            },
          ),
        );
      },
    );
  }
}
