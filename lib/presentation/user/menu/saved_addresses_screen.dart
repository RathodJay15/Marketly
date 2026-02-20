import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/address_model.dart';
import 'package:marketly/data/models/user_model.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  final TextEditingController _newAddressCtrl = TextEditingController();
  bool _isAddingAddress = false;

  @override
  void dispose() {
    _newAddressCtrl.dispose();
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

            return ListView(children: [_titleSection(), _addressList(user)]);
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Title
  // ------------------------------------------------------------
  Widget _titleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left_rounded, size: 35),
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
          Text(
            AppConstants.savedAdrs,
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

  // ------------------------------------------------------------
  // Address list
  // ------------------------------------------------------------
  Widget _addressList(UserModel user) {
    final addresses = user.addresses;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: addresses.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _addNewAddressField(user);
        }

        final address = addresses[index - 1];
        final isDefault = address.isDefault == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          child: ListTile(
            title: Text(
              address.address,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: isDefault
                ? Text(
                    AppConstants.defaultAdrs,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  )
                : null,
            leading: Switch(
              value: isDefault,
              activeThumbColor: Theme.of(context).colorScheme.onInverseSurface,
              inactiveThumbColor: Theme.of(context).colorScheme.onPrimary,
              inactiveTrackColor: Theme.of(
                context,
              ).colorScheme.onSecondaryContainer,
              onChanged: (value) {
                if (!value) return;
                _setDefaultAddress(user: user, addressId: address.id);
              },
            ),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 20,
                  onPressed: () {
                    _showEditDialog(user: user, address: address);
                  },
                  icon: const Icon(Icons.edit),
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                IconButton(
                  iconSize: 20,
                  onPressed: () {
                    _confirmDeleteAddress(
                      context: context,
                      user: user,
                      address: address,
                    );
                  },
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // Add new address field
  // ------------------------------------------------------------
  Widget _addNewAddressField(UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _newAddressCtrl,
        readOnly: !_isAddingAddress,
        minLines: 1,
        maxLines: 3,
        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        decoration: InputDecoration(
          hintText: AppConstants.addNewAdrs,
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
            Icons.location_on_outlined,
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
          suffixIcon: _isAddingAddress
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      onPressed: () {
                        _newAddressCtrl.clear();
                        setState(() {
                          _isAddingAddress = false;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      onPressed: () async {
                        final text = _newAddressCtrl.text.trim();
                        if (text.isEmpty) return;

                        await _addAddress(user: user, addressText: text);

                        _newAddressCtrl.clear();
                        setState(() {
                          _isAddingAddress = false;
                        });
                      },
                    ),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.add),
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  onPressed: () {
                    setState(() {
                      _isAddingAddress = true;
                    });
                  },
                ),
        ),
        onTap: () {
          if (!_isAddingAddress) {
            setState(() => _isAddingAddress = true);
          }
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // Add address logic
  // ------------------------------------------------------------
  Future<void> _addAddress({
    required UserModel user,
    required String addressText,
  }) async {
    final newAddress = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      address: addressText,
      isDefault: user.addresses.isEmpty,
    );

    final updatedAddresses = [...user.addresses, newAddress];

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'addresses': updatedAddresses.map((e) => e.toMap()).toList(),
    });

    context.read<UserProvider>().setUser(
      user.copyWith(addresses: updatedAddresses),
    );
  }

  // ------------------------------------------------------------
  // edit address logic
  // ------------------------------------------------------------
  Future<void> _editAddress({
    required UserModel user,
    required String addressId,
    required String newAddressText,
  }) async {
    final updatedAddresses = user.addresses.map((addr) {
      if (addr.id == addressId) {
        return addr.copyWith(address: newAddressText);
      }
      return addr;
    }).toList();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'addresses': updatedAddresses.map((e) => e.toMap()).toList(),
    });

    context.read<UserProvider>().setUser(
      user.copyWith(addresses: updatedAddresses),
    );
  }

  void _showEditDialog({
    required UserModel user,
    required AddressModel address,
  }) {
    final controller = TextEditingController(text: address.address);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          AppConstants.editAdrs,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppConstants.cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newText = controller.text.trim();
              if (newText.isEmpty) return;

              Navigator.pop(context);

              await _editAddress(
                user: user,
                addressId: address.id,
                newAddressText: newText,
              );
            },
            child: Text(
              AppConstants.save,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Set default address
  // ------------------------------------------------------------
  Future<void> _setDefaultAddress({
    required UserModel user,
    required String addressId,
  }) async {
    final updatedAddresses = user.addresses.map((addr) {
      return AddressModel(
        id: addr.id,
        address: addr.address,
        isDefault: addr.id == addressId,
      );
    }).toList();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'addresses': updatedAddresses.map((e) => e.toMap()).toList(),
    });

    context.read<UserProvider>().setUser(
      user.copyWith(addresses: updatedAddresses),
    );
  }

  void _confirmDeleteAddress({
    required BuildContext context,
    required UserModel user,
    required AddressModel address,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          '${AppConstants.delete} ${AppConstants.adrs}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        content: Text(
          AppConstants.areYouSureDeleteAdrs,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppConstants.cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAddress(user: user, addressId: address.id);
            },
            child: Text(
              AppConstants.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress({
    required UserModel user,
    required String addressId,
  }) async {
    // Remove selected address
    final List<AddressModel> updatedAddresses = user.addresses
        .where((a) => a.id != addressId)
        .toList();

    //  If deleted address was default → assign new default
    if (updatedAddresses.isNotEmpty &&
        !updatedAddresses.any((a) => a.isDefault)) {
      updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
    }

    // Update Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'addresses': updatedAddresses.map((e) => e.toMap()).toList(),
    });

    // Update Provider
    context.read<UserProvider>().setUser(
      user.copyWith(addresses: updatedAddresses),
    );
  }
}
