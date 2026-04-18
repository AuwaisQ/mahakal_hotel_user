import 'package:flutter/material.dart';

class BlogLanguageProvider with ChangeNotifier {
  bool _isEnglish = false; // Default to English
  int _selectedLanguage = 2; // Default to English

  bool get isEnglish => _isEnglish;
  int get selectedLanguage => _selectedLanguage;

  void toggleLanguage() {
    _isEnglish = !_isEnglish;
    _selectedLanguage = _isEnglish ? 2 : 1;
    notifyListeners();
  }
}
