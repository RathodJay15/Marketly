import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/data/models/address_model.dart';
import 'package:marketly/presentation/user/menu/address/map_screen.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
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
  String? selectedAddressId;

  void _saveAddressDetails() {
    final orderProvider = context.read<OrderProvider>();
    final user = context.read<UserProvider>().user;

    if (selectedAddressId == null) return;
    final addresses = user!.addresses;

    if (addresses == null || addresses.isEmpty) return;

    final selectedAddress = addresses.firstWhere(
      (a) => a.id == selectedAddressId,
    );

    orderProvider.setAddress(selectedAddress.toMap());

    FocusManager.instance.primaryFocus?.unfocus();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleSection(),
        Expanded(child: _adrsList()),
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
                    _saveAddressDetails();
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

  Widget _adrsList() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final addresses = user.addresses ?? [];
        if (addresses.isEmpty) {
          return Center(
            child: Text(
              AppConstants.emptyAddressTitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          );
        }

        if (selectedAddressId == null && addresses.isNotEmpty) {
          final defaultAddress = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
          selectedAddressId = defaultAddress.id;
        }

        return RadioGroup<String>(
          groupValue: selectedAddressId,
          onChanged: (value) {
            setState(() {
              selectedAddressId = value;
            });
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: addresses.length,
            itemBuilder: (builder, index) {
              final AddressModel address = user.addresses![index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: Slidable(
                  key: ValueKey(address.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.60,
                    children: [
                      SlidableAction(
                        onPressed: (context) async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapScreen(address: address),
                            ),
                          );
                        },
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                        icon: Icons.edit,
                        label: AppConstants.editAdrs,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          if (address.isDefault) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  AppConstants.cantDeleteDefault,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onInverseSurface,
                                  ),
                                ),
                                content: Text(
                                  AppConstants.setOtherAdrsDefaultFirst,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      AppConstants.yes,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onInverseSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          final confirm = await MarketlyDialog.showMyDialog(
                            context: context,
                            title: AppConstants.deleteAdrs,
                            content: AppConstants.areYouSureDeleteAdrs,
                            actionN: AppConstants.cancel,
                            actionY: AppConstants.delete,
                          );
                          if (confirm == true) {
                            userProvider.deleteAddress(address.id);
                          }
                        },
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.onSurface,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                        icon: Icons.delete,
                        label: AppConstants.deleteAdrs,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                  child: _listCard(address),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _listCard(AddressModel address) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddressId = address.id;
        });
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    child: Text(
                      address.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      if (address.isDefault)
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                            ),
                          ),
                          child: Text(
                            AppConstants.defaultAdrs,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                            ),
                          ),
                        ),

                      Radio<String>(
                        value: address.id,
                        fillColor: WidgetStateProperty.resolveWith<Color>((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(
                              context,
                            ).colorScheme.onInverseSurface;
                          }
                          return Theme.of(context).colorScheme.onPrimary;
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Divider(color: Theme.of(context).colorScheme.onPrimary),

            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    address.recipientName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Iconoir(
                    IconoirIcons.phone,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    address.recipientPhone,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              address.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppConstants.savedAdrs,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MapScreen(address: null)),
              );
            },
            color: Theme.of(context).colorScheme.onInverseSurface,
            icon: Iconoir(
              IconoirIcons.plus,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
