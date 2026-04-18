import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mahakal/utill/app_constants.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../model/shlokModel.dart';

class ShareVerse extends ChangeNotifier {
  final ScreenshotController screenshotController = ScreenshotController();

  void shareCustomDesign(Verse verse, BuildContext context) async {
    try {
      // Capture the widget as an image
      Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/verse.png';
        final file = File(path)..writeAsBytesSync(image);

        String shareUrl = '';

        shareUrl = "${AppConstants.baseUrl}/download";

        // Share the image with text including both URLs
        await Share.shareXFiles([XFile(path)],
            text: "📜 **श्रीमद्भगवद्गीता का अमृत वचन** ✨\n"
                "अब पढ़ें Mahakal.com ऐप पर! 🔱💖\n"
                "अभी डाउनलोड करें और दिव्य ज्ञान प्राप्त करें! 📲🙏\n\n"
                "🔹Download App Now: $shareUrl");
      }
    } catch (error) {
      print("Error sharing image: $error");
    }
    notifyListeners();
  }
}
