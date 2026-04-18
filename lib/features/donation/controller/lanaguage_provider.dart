import 'package:flutter/cupertino.dart';

class LanguageProvider with ChangeNotifier {
  String _language = 'hindi';

  String get language => _language;

  void toggleLanguage() {
    _language = _language == 'english' ? 'hindi' : 'english';
    notifyListeners();
  }
}
