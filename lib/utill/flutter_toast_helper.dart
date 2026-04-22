import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  // General function
  static void showToast({
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }

  // Success Toast
  static void showSuccess(String message) {
    showToast(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  // Error Toast
  static void showError(String message) {
    showToast(
      message: message,
      backgroundColor: Colors.red,
    );
  }

  // Info Toast
  static void showInfo(String message) {
    showToast(
      message: message,
      backgroundColor: Colors.blue,
    );
  }
}


Widget placeholderImage() {
  return Container(
    child: Image.asset(
      'assets/images/mahakal.jpeg',
      fit: BoxFit.cover,
    ),
  );
}

class NoImageWidget extends StatelessWidget {
  const NoImageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Image.asset(
          "assets/images/no_image.png",
          fit: BoxFit.fill,
        ));
  }
}