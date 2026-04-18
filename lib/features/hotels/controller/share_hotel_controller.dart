import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareHotelController extends ChangeNotifier {

  Future<void> shareHotel(
      BuildContext context,
      String shareUrl,
      String imageUrl,
      ) async {
    try {
      final uri = Uri.parse(imageUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath =
            '${tempDir.path}/hotel_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final exists = await file.exists();
        if (!exists) {
          debugPrint('Share file write failed: $filePath');
          _shareWithoutImage(context, shareUrl);
          return;
        }

        final message =
            "🏨 अब बुक करें अपना मनपसंद होटल! 🏨\n\n"
            "Mahakal.com ऐप पर शानदार और आरामदायक होटल चुनें और अपनी यात्रा को बनाएं यादगार। ✨\n"
            "आज ही बुक करें और बेहतरीन सुविधा का लाभ उठाएं! 🙏\n\n"
            "🔹 अपना होटल बुक करें यहाँ से:\n$shareUrl";

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
              name: 'hotel.jpg',
              mimeType: 'image/jpeg',
            ),
          ],
          text: message,
          subject: 'अपना होटल अभी बुक करें!',
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
        "🏨 अब बुक करें अपना मनपसंद होटल! 🏨\n\n"
        "Mahakal.com ऐप पर शानदार और आरामदायक होटल चुनें और अपनी यात्रा को बनाएं यादगार। ✨\n"
        "आज ही बुक करें और बेहतरीन सुविधा का लाभ उठाएं! 🙏\n\n"
        "🔹 अपना होटल बुक करें यहाँ से:\n$shareUrl";

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
      subject: 'अपना होटल अभी बुक करें!',
      sharePositionOrigin: shareOrigin,
    );
  }
}
