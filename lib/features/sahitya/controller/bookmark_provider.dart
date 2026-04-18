import 'package:flutter/foundation.dart';
import '../data_base/sahitya_db_helper.dart';
import '../model/shlokModel.dart';

class BookmarkProvider with ChangeNotifier {
  List<Verse> _bookMarkedShlokes = [];

  List<Verse> get bookMarkedShlokes => _bookMarkedShlokes;

  BookmarkProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    _bookMarkedShlokes = await VerseDBHelper.getBookmarks();
    notifyListeners();
  }

  Future<void> toggleBookmark(Verse shlok) async {
    // Check if the shlok is already bookmarked
    bool isBookmarked = _bookMarkedShlokes.any((bookmarked) =>
        bookmarked.verseData?.audioUrl ==
        shlok.verseData?.audioUrl); // Assuming audioUrl is unique

    if (isBookmarked) {
      // Remove the bookmark
      await VerseDBHelper.deleteBookmark(shlok);
      _bookMarkedShlokes.removeWhere((bookmarked) =>
          bookmarked.verseData?.audioUrl == shlok.verseData?.audioUrl);
    } else {
      // Add the bookmark
      await VerseDBHelper.insertBookmark(shlok);
      _bookMarkedShlokes.add(shlok);
    }

    // Notify listeners after updating bookmarks
    notifyListeners();
  }
}
