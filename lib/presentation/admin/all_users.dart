import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';

class AllUsers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _allUsersState();
}

class _allUsersState extends State<AllUsers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppConstants.users,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Text(AppConstants.users),
    );
  }
}
