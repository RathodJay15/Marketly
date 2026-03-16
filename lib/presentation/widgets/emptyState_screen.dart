import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';

class EmptystateScreen {
  static Widget emptyState({
    required icon,
    required title,
    required subtitle,
    required context,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Iconoir(
          icon,
          color: Theme.of(context).colorScheme.onInverseSurface,
          size: 70,
        ),
        SizedBox(height: 15),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontSize: 25,
          ),
        ),
        SizedBox(height: 10),

        SizedBox(
          width: 300,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
