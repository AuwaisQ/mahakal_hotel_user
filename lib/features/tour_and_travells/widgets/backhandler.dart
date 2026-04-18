import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackHandler {
  static Future<bool> handle({
    required BuildContext context,
    required bool showDialog,
  }) async {
    if (showDialog) {
      bool shouldExit = await _showExitDialog(context);
      if (shouldExit) {
        Navigator.of(context).pop(); // ✅ only previous screen
      }
      return false;
    } else {
      Navigator.of(context).pop();
      return false;
    }
  }

  static Future<bool> _showExitDialog(BuildContext context) async {
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Confirm Exit"),
        content: const Text("Are you sure you want to go back?"),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            isDestructiveAction: true,
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }
}
