import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:marketly/auth_gate.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/data_instance/validators.dart';
import 'package:marketly/data/models/user_model.dart';
import 'package:marketly/presentation/user/menu/saved_addresses_screen.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:marketly/data/services/image_service.dart';

class MyAccountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _myAccountScreenState();
}

class _myAccountScreenState extends State<MyAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  bool _initialized = false;
  bool _isPickingImage = false;

  String? selectedAddressId;

  final ImageService _profilePicService = ImageService();

  final ImagePicker _imagePicker = ImagePicker();

  final Map<String, bool> _editMode = {
    'name': false,
    'phone': false,
    'city': false,
    'state': false,
    'country': false,
    'pincode': false,
  };

  Future<File?> _pickImage() async {
    if (_isPickingImage) return null;

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
                  size: 30,
                  color: Theme.of(context).colorScheme.onInverseSurface,
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
              ListTile(
                leading: Icon(
                  Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  size: 30,
                ),
                title: Text(
                  AppConstants.deleteProfilePic,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 23,
                  ),
                ),
                onTap: () {
                  _deleteProfileImage();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return null;

    _isPickingImage = true;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (picked == null) return null;

      return File(picked.path);
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _changeProfilePicture(UserModel user) async {
    final imageFile = await _pickImage();
    if (imageFile == null) return;

    // Upload to Firebase Storage
    final imageUrl = await _profilePicService.uploadProfileImage(
      uid: user.uid,
      imageFile: imageFile,
    );

    if (imageUrl == null) return;

    //  Update Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'profilePic': imageUrl,
    });

    //  Update local provider
    context.read<UserProvider>().setUser(user.copyWith(profilePic: imageUrl));
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.user;

            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              scrollDirection: Axis.vertical,
              children: [
                _titleSection(),
                SizedBox(height: 20),
                _profilePictureSection(user),
                _detailsForm(user),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _titleSection() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.chevron_left_rounded),
            color: Theme.of(context).colorScheme.onInverseSurface,
            iconSize: 35,
          ),
          Text(
            AppConstants.myAccount,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _profilePictureSection(UserModel user) {
    final hasValidUrl =
        user.profilePic != null &&
        user.profilePic!.isNotEmpty &&
        user.profilePic!.startsWith('http');
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Stack(
            children: [
              // Image / Placeholder
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                ),
                clipBehavior: Clip.antiAlias,
                child: hasValidUrl
                    ? Image.network(
                        user.profilePic!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          child: const Icon(Icons.person, size: 60),
                        ),
                      )
                    : Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        child: const Icon(Icons.person, size: 60),
                      ),
              ),

              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _isPickingImage
                      ? null
                      : () => _changeProfilePicture(user),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            user.email.isEmpty ? AppConstants.username : user.email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsForm(UserModel user) {
    _initFromUser(user);
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),

          _editableField(
            fieldKey: 'name',
            controller: nameCtrl,
            hint: AppConstants.username,
            icon: Icons.person_outline,
            validator: Validators.username,
          ),

          _editableField(
            fieldKey: 'phone',
            controller: phoneCtrl,
            hint: AppConstants.phone,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: Validators.phone,
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SavedAddressesScreen()),
              );
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: addressCtrl,
                readOnly: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: AppConstants.adrs,
                  filled: true,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  suffixIcon: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          _editableField(
            fieldKey: 'city',
            controller: cityCtrl,
            hint: AppConstants.ct,
            icon: Icons.location_city_outlined,
            validator: Validators.city,
          ),
          _editableField(
            fieldKey: 'state',
            controller: stateCtrl,
            hint: AppConstants.state,
            icon: Icons.map_outlined,
            validator: Validators.city,
          ),
          _editableField(
            fieldKey: 'country',
            controller: countryCtrl,
            hint: AppConstants.cntry,
            icon: Icons.public_rounded,
            validator: Validators.city,
          ),
          _editableField(
            fieldKey: 'pincode',
            controller: pincodeCtrl,
            hint: AppConstants.pincode,
            icon: Icons.pin_outlined,
            validator: Validators.city,
          ),
          SizedBox(height: 30),
          _deleteAccountBTN(user.uid),
        ],
      ),
    );
  }

  Widget _editableField({
    required String fieldKey,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isEditing = _editMode[fieldKey] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: !isEditing,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
          fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),

          // suffix icon
          suffixIcon: IconButton(
            icon: Icon(isEditing ? Icons.check_rounded : Icons.edit),
            color: Theme.of(context).colorScheme.onInverseSurface,
            onPressed: () async {
              if (isEditing) {
                // SAVE
                if (_formKey.currentState!.validate()) {
                  await _updateUserField(fieldKey);
                  setState(() => _editMode[fieldKey] = false);
                }
              } else {
                // ENABLE EDIT
                setState(() => _editMode[fieldKey] = true);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _deleteAccountBTN(String uid) {
    return ElevatedButton(
      onPressed: () async {
        final confirm = await MarketlyDialog.showMyDialog(
          context: context,
          title: AppConstants.deleteAcc,
          content: AppConstants.areYouSureDeleteAcc,
          actionN: AppConstants.cancel,
          actionY: AppConstants.delete,
        );
        if (confirm == true) {
          await _deleteAccount(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        minimumSize: const Size(double.infinity, 50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        AppConstants.deleteAcc,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .update({
            'isDeleted': true,
            'deletedAt': FieldValue.serverTimestamp(), // optional audit field
          });
      // Clear provider
      userProvider.clearUser();
      context.read<NavigationProvider>().setScreenIndex(
        0,
      ); // set navbar to home
      context.read<CartProvider>().stopListening();

      // Navigate to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _deleteProfileImage() async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    try {
      // 🔥 Only delete if URL exists
      if (user.profilePic != null && user.profilePic!.isNotEmpty) {
        final ref = FirebaseStorage.instance.refFromURL(user.profilePic!);
        await ref.delete();
      }

      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profilePic': ''},
      );

      // Update Provider
      final updatedUser = user.copyWith(profilePic: '');
      context.read<UserProvider>().setUser(updatedUser);
    } catch (e) {
      debugPrint("Delete profile error: $e");
    }
  }

  Future<void> _updateUserField(String fieldKey) async {
    final user = context.read<UserProvider>().user!;
    final Map<String, dynamic> updates = {};

    switch (fieldKey) {
      case 'name':
        updates['name'] = nameCtrl.text.trim();
        break;
      case 'phone':
        updates['phone'] = phoneCtrl.text.trim();
        break;
      case 'city':
        updates['city'] = cityCtrl.text.trim();
        break;
      case 'state':
        updates['state'] = stateCtrl.text.trim();
        break;
      case 'country':
        updates['country'] = countryCtrl.text.trim();
        break;
      case 'pincode':
        updates['pincode'] = pincodeCtrl.text.trim();
        break;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update(updates);

    context.read<UserProvider>().setUser(
      user.copyWith(
        name: updates['name'],
        phone: updates['phone'],
        city: updates['city'],
        state: updates['state'],
        country: updates['country'],
        pincode: updates['pincode'],
      ),
    );
  }
}
