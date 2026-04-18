import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareTourController extends ChangeNotifier {

  Future<void> shareTour(
      BuildContext context,
      String shareUrl,
      String imageUrl,
      ) async {
    try {
      final uri = Uri.parse(imageUrl);

      // Try fetching the image regardless of scheme. Note: iOS may block
      // non-HTTPS requests due to App Transport Security (ATS). If the
      // request fails we fall back to text-only sharing.
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Save to temporary directory so the file is accessible to the
        // iOS share sheet and will be cleaned up by the system.
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/tour_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        final exists = await file.exists();
        if (!exists) {
          debugPrint('Share file write failed: $filePath');
          _shareWithoutImage(context, shareUrl);
          return;
        }

        final message =
            "🛕 अब करें अपनी पवित्र यात्रा की बुकिंग! 🛕\n\n"
            "Mahakal.com ऐप पर अपनी पसंदीदा यात्रा चुनें और घर बैठे दर्शन का लाभ उठाएं। 🚩\n"
            "आज ही बुक करें और भक्ति का अनुभव पाएं! 🙏\n\n"
            "🔹 अपनी यात्रा बुक करें यहाँ से:\n$shareUrl";

        final box = context.findRenderObject() as RenderBox?;
        final shareOrigin = box != null
            ? (box.localToGlobal(Offset.zero) & box.size)
            : Rect.fromLTWH(
                (MediaQuery.of(context).size.width / 2) - 1,
                (MediaQuery.of(context).size.height / 2) - 1,
                2,
                2,
              );

        await Share.shareXFiles(
          [
            XFile(
              file.path,
              name: 'tour.jpg',
              mimeType: 'image/jpeg',
            ),
          ],
          text: message,
          subject: 'अपनी यात्रा अभी बुक करें!',
          sharePositionOrigin: shareOrigin,
        );
      } else {
        _shareWithoutImage(context, shareUrl);
      }
    } catch (e) {
      debugPrint("Share error: $e");
      _shareWithoutImage(context, shareUrl);
    }
  }

  void _shareWithoutImage(BuildContext context, String shareUrl) {
    final message =
        "🛕 अब करें अपनी पवित्र यात्रा की बुकिंग! 🛕\n\n"
        "Mahakal.com ऐप पर अपनी पसंदीदा यात्रा चुनें और घर बैठे दर्शन का लाभ उठाएं। 🚩\n"
        "आज ही बुक करें और भक्ति का अनुभव पाएं! 🙏\n\n"
        "🔹 अपनी यात्रा बुक करें यहाँ से:\n$shareUrl";
    final box = context.findRenderObject() as RenderBox?;
    final shareOrigin = box != null
        ? (box.localToGlobal(Offset.zero) & box.size)
        : Rect.fromLTWH(
            (MediaQuery.of(context).size.width / 2) - 1,
            (MediaQuery.of(context).size.height / 2) - 1,
            2,
            2,
          );

    Share.share(
      message,
      subject: 'अपनी यात्रा अभी बुक करें!',
      sharePositionOrigin: shareOrigin,
    );
  }
}
