// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:share_plus/share_plus.dart';
// import '../../../splash/controllers/splash_controller.dart';
// import '../../model/hanuman_chalisa_model.dart';
//
// class ShareHanumanChalisa extends ChangeNotifier {
//   final ScreenshotController screenshotController = ScreenshotController();
//
//   void shareCustomDesign(HanumanChalisaModel chalisa, BuildContext context) async {
//     try {
//       // Capture the widget as an image
//       Uint8List? image = await screenshotController.capture();
//       if (image != null) {
//         final directory = await getTemporaryDirectory();
//         final path = '${directory.path}/chalisa.png';
//         final file = File(path)..writeAsBytesSync(image);
//
//         // Default URL
//         String? appUrl = 'https://google.com';
//
//         // SplashController se dynamically URL fetch karna
//         var splashController = Provider.of<SplashController>(context, listen: false);
//         if (Platform.isAndroid) {
//           appUrl = splashController.configModel?.userAppVersionControl?.forAndroid?.link;
//         } else if (Platform.isIOS) {
//           appUrl = splashController.configModel?.userAppVersionControl?.forIos?.link;
//         }
//
//         // Null check (Agar appUrl null ho to default Google ka link use ho)
//         appUrl ??= 'https://google.com';
//
//         // Share the image with text
//         await Share.shareXFiles(
//           [XFile(path)],
//           text: "🔱 **हनुमान चालीसा की चोपाई** 🙏✨\n"
//               "अब पढ़ें **महाकाल ऐप** पर! 🚩🔥\n"
//               "अभी डाउनलोड करें और श्री हनुमान जी की कृपा प्राप्त करें! 📲💖\n"
//               "Download Now: $appUrl",
//         );
//       }
//     } catch (error) {
//       print("Error sharing image: $error");
//     }
//
//     notifyListeners();
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../utill/app_constants.dart';
import '../../model/hanuman_chalisa_model.dart';

class ShareHanumanChalisa extends ChangeNotifier {
  final ScreenshotController screenshotController = ScreenshotController();

  void shareCustomDesign(
      HanumanChalisaModel chalisa, BuildContext context) async {
    try {
      // Capture the widget as an image
      Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/chalisa.png';
        final file = File(path)..writeAsBytesSync(image);

        String shareUrl = '';
        shareUrl = "${AppConstants.baseUrl}/download";

        // Share image with text and both URLs
        await Share.shareXFiles([XFile(path)],
            text: "🔱 **हनुमान चालीसा की चोपाई** 🙏✨\n"
                "अब पढ़ें Mahakal.com ऐप पर! 🚩🔥\n"
                "अभी डाउनलोड करें और श्री हनुमान जी की कृपा प्राप्त करें! 📲💖\n\n"
                "Download App Now: $shareUrl");
      }
    } catch (error) {
      print("Error sharing image: $error");
    }

    notifyListeners();
  }
}
