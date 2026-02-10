import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
            'Saved Addresses',
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
      padding: const EdgeInsets.all(20),
      itemCount: addresses.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _addNewAddressField(user);
        }

        final address = addresses[index - 1];
        final isDefault = address['isDefault'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          child: ListTile(
            title: Text(
              address['address'],
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: isDefault
                ? Text(
                    'Default address',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  )
                : null,
            leading: Switch(
              value: isDefault,
              activeColor: Theme.of(context).colorScheme.onInverseSurface,
              inactiveThumbColor: Theme.of(context).colorScheme.onPrimary,
              inactiveTrackColor: Theme.of(
                context,
              ).colorScheme.onSecondaryContainer,
              onChanged: (value) {
                if (!value) return;
                _setDefaultAddress(user: user, addressId: address['id']);
              },
            ),
            trailing: IconButton(
              onPressed: () {
                _confirmDeleteAddress(
                  context: context,
                  user: user,
                  address: address,
                );
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
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
        decoration: InputDecoration(
          hintText: 'Add new address',
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
          suffixIcon: IconButton(
            icon: Icon(
              _isAddingAddress ? Icons.check : Icons.add,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            onPressed: () async {
              if (!_isAddingAddress) {
                setState(() => _isAddingAddress = true);
                return;
              }

              final text = _newAddressCtrl.text.trim();
              if (text.isEmpty) return;

              await _addAddress(user: user, addressText: text);

              _newAddressCtrl.clear();
              setState(() => _isAddingAddress = false);
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
    final newAddress = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'address': addressText,
      'isDefault': user.addresses.isEmpty,
    };

    final updatedAddresses = [...user.addresses, newAddress];

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'addresses': updatedAddresses,
    });

    context.read<UserProvider>().setUser(
      user.copyWith(addresses: updatedAddresses),
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
      return {
        'id': addr['id'],
        'address': addr['address'],
        'isDefault': addr['id'] == addressId,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'addresses': updatedAddresses,
    });

    context.read<UserProvider>().setUser(
      user.copyWith(addresses: updatedAddresses),
    );
  }

  void _confirmDeleteAddress({
    required BuildContext context,
    required UserModel user,
    required Map<String, dynamic> address,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete address',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAddress(user: user, addressId: address['id']);
            },
            child: Text(
              'Delete',
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
    final List<Map<String, dynamic>> updatedAddresses = user.addresses
        .where((a) => a['id'] != addressId)
        .toList();

    //  If deleted address was default → assign new default
    if (updatedAddresses.isNotEmpty &&
        !updatedAddresses.any((a) => a['isDefault'] == true)) {
      updatedAddresses[0] = {...updatedAddresses[0], 'isDefault': true};
    }

    // Update Firestore
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'addresses': updatedAddresses,
    });

    // Update Provider
    context.read<UserProvider>().setUser(
      user.copyWith(addresses: updatedAddresses),
    );
  }
}
