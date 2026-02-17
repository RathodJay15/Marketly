import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/user_model.dart';

class UserDetails extends StatefulWidget {
  final UserModel user;

  UserDetails({required this.user});
  @override
  State<StatefulWidget> createState() => _userDetailsScreen();
}

class _userDetailsScreen extends State<UserDetails> {
  @override
  Widget build(BuildContext context) {
    final UserModel user = widget.user;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              AppConstants.usrDetails,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            SizedBox(width: 10),
            if (user.isDeleted)
              Text(
                AppConstants.inActive,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _UserDetails(user),
    );
  }

  Widget _UserDetails(UserModel user) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      children: [
        _sectionTitle(AppConstants.usrDetails),
        _greyCard(
          children: [
            _row(AppConstants.userID, user.uid),
            _row(AppConstants.email, user.email),
            _row(AppConstants.username, user.name),
            _row(AppConstants.phone, user.phone),
            _row(AppConstants.ct, user.city),
            _row(AppConstants.state, user.state),
            _row(AppConstants.cntry, user.country),
            _row(AppConstants.pincode, user.pincode),
          ],
        ),
        SizedBox(height: 8),
        _sectionTitle(AppConstants.adrs),
        _greyCard(
          children: user.addresses.map((address) {
            final formattedAddress = address.address;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                formattedAddress,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _greyCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
