import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/address_model.dart';
import 'package:marketly/data/models/user_model.dart';
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

            SliverToBoxAdapter(child: _addressList()),
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
          icon: Iconoir(
            IconoirIcons.navArrowLeft,
            color: Theme.of(context).colorScheme.onInverseSurface,
            size: 35,
          ),
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
          onPressed: () {},
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

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: user.addresses.length,
          itemBuilder: (builder, index) {
            final AddressModel address = user.addresses[index];
            return Slidable(
              key: ValueKey(address.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(), // smooth slide animation
                extentRatio: 0.25, // how much space action takes
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      final confirm = await MarketlyDialog.showMyDialog(
                        context: context,
                        title: AppConstants.removeItem,
                        content: AppConstants.areYouSureRemoveCartItem,
                        actionN: AppConstants.cancel,
                        actionY: AppConstants.removeItem,
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
                    label: AppConstants.removeItem,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),

              child: _listCard(address),
            );
          },
        );
      },
    );
  }

  Widget _listCard(AddressModel address) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
