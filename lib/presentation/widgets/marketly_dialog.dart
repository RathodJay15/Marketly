import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';

class MarketlyDialog {
  static Future<bool?> showMyDialog({
    required BuildContext context,
    String title = 'Confirm',
    String content = 'Are you sure?',
    String actionN = AppConstants.no,
    String actionY = AppConstants.yes,
    Color? actionNColor,
    Color? actionYColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              actionN,
              style: TextStyle(
                color:
                    actionNColor ??
                    Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              actionY,
              style: TextStyle(
                color: actionYColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
