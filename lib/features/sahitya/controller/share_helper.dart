import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../utill/app_constants.dart';

class ShareHelper {
  static void shareContent(BuildContext context, String title) {
    String shareUrl = '';
    shareUrl = "${AppConstants.baseUrl}/download";

    // Final share content with both URLs
    String contentToShare = "**$title** 🌞🙏 \n"
        "अब पढ़ें Mahakal.com ऐप पर! 🔱💖 \n"
        "अभी डाउनलोड करें और पुण्य लाभ प्राप्त करें! 📲🙏 \n\n"
        "🔹Download App Now: $shareUrl";

    Share.share(contentToShare, subject: 'Check out this blog!');
  }
}
