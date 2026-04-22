import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utill/images.dart';

class MahakalPaymentProcessing extends StatefulWidget {
  const MahakalPaymentProcessing({super.key});

  @override
  _MahakalPaymentProcessingState createState() =>
      _MahakalPaymentProcessingState();
}

class _MahakalPaymentProcessingState extends State<MahakalPaymentProcessing> {
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    // Disable both hardware and software back button
    SystemChannels.navigation.invokeMethod('setRestorationDisabled', true);
  }

  @override
  void dispose() {
    SystemChannels.navigation.invokeMethod('setRestorationDisabled', false);
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final shouldExit = _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2);

    if (shouldExit) {
      return true; // Allow pop
    } else {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Prevent pop on first press
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Title
                // Text(
                //   'Mahakal.com',
                //   style: TextStyle(
                //     fontSize: 28,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
                Hero(
                    tag: "1",
                    child: Image.asset(Images.logoWithNameImage, height: 50)),
                const SizedBox(height: 40),

                // Processing Indicator
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
                const SizedBox(height: 30),

                // Processing Text
                const Text(
                  'Processing Your Payment...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Important Warning
                Text(
                  'Do not press back button or close the app\nPayment will complete automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
