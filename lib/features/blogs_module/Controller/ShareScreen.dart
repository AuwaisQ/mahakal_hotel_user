// Platform check ke liye
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import '../../../utill/app_constants.dart';
import '../model/blog_details_model.dart';

class ShareBlogs extends ChangeNotifier {
  void shareSong(BlogData myData, BuildContext context) {
    print("My Share Song ${myData.title}");

    // HTML content ko parse aur trim karo
    String parsedContent = HtmlParser.parseHTML(myData.content ?? '').text.trim();
    String shortContent = parsedContent.length > 500
        ? "${parsedContent.substring(0, 500)}..."
        : parsedContent;

    String shareUrl = '';
    shareUrl = "${AppConstants.baseUrl}/download";

    // Final share message with both URLs
    String shareText = "📜 **${myData.title}** 🙏✨\n"
        "$shortContent\n\n"
        "अब पढ़ें Mahakal.com ऐप पर! 🔱🔥\n"
        "अभी डाउनलोड करें और आध्यात्मिक ज्ञान प्राप्त करें! 📲💖\n\n"
        "🔹Download App Now: $shareUrl";

    Share.share(
      shareText,
      subject: '📖 धार्मिक ज्ञान और व्रत कथाएं',
    );

    notifyListeners();
  }
}
