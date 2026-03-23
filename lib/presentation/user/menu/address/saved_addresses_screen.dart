import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/data/models/address_model.dart';
import 'package:marketly/presentation/user/menu/address/map_screen.dart';
import 'package:marketly/presentation/widgets/emptyState_screen.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: CustomScrollView(
          physics: NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              floating: true,
              snap: true,
              toolbarHeight: 70,
              titleSpacing: 20,
              title: _titleSection(),
            ),

            SliverFillRemaining(
              hasScrollBody: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _addressList()),
                  _addButton(),
                ],
              ),
            ),
          ],
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
          color: Theme.of(context).colorScheme.onInverseSurface,
          icon: Iconoir(IconoirIcons.navArrowLeft, size: 35),
        ),
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
              MaterialPageRoute(builder: (_) => MapScreen()),
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
    );
  }

  Widget _addressList() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final addresses = user.addresses ?? [];

        if (addresses.isEmpty) {
          return EmptystateScreen.emptyState(
            icon: IconoirIcons.pinAlt,
            title: AppConstants.emptyAddressTitle,
            subtitle: AppConstants.emptyAddressSubtitle,
            context: context,
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: addresses.length,
          itemBuilder: (builder, index) {
            final AddressModel address = addresses[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                      backgroundColor: Theme.of(context).colorScheme.onSurface,
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
        );
      },
    );
  }

  Widget _listCard(AddressModel address) {
    return Container(
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
                if (address.isDefault)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    child: Text(
                      AppConstants.defaultAdrs,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 16,
                      ),
                    ),
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
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MapScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            minimumSize: const Size(double.infinity, 50.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            AppConstants.addNewAdrs,
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
}
