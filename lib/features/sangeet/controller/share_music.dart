import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../utill/app_constants.dart';
import '../../splash/controllers/splash_controller.dart';
import '../model/sangeet_model.dart';

class ShareMusic extends ChangeNotifier {
  void shareSong(Sangeet song, BuildContext context) {
    String shareUrl = '';
    shareUrl = "${AppConstants.baseUrl}/download";

    // Final share message with both URLs
    String contentToShare = "🎵 **${song.title}** - ${song.singerName} 🎶\n"
        "अब सुनें Mahakal.com ऐप पर! 🔱✨\n"
        "अभी डाउनलोड करें और संगीत का आनंद लें! 🎧💖\n\n"
        "🔹Download App Now: $shareUrl";

    Share.share(contentToShare, subject: 'संगीत का आनंद लें!');

    notifyListeners();
  }
}
