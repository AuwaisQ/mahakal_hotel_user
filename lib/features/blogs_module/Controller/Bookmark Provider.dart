import 'package:flutter/foundation.dart';
import '../database/bookmark_database_helper.dart';
import '../model/SubCategory_model.dart';

class BlogSaveProvider with ChangeNotifier {
  List<BlogSubCategoryData> _bookMarkedBlogs = [];

  List<BlogSubCategoryData> get bookMarkedBlogs => _bookMarkedBlogs;

  BlogSaveProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    // Load bookmarks from the database using the DBHelper class
    _bookMarkedBlogs = await DBHelper.getBookmarks();
    notifyListeners();
  }

  Future<void> toggleBookmark(BlogSubCategoryData shlok) async {
    // Check if the shlok is already bookmarked by comparing the title
    bool isBookmarked = _bookMarkedBlogs.any(
      (bookmarked) => bookmarked.title == shlok.title,
    );

    if (isBookmarked) {
      // If already bookmarked, remove the bookmark
      await DBHelper.deleteBookmark(shlok);
      _bookMarkedBlogs.removeWhere(
        (bookmarked) => bookmarked.title == shlok.title,
      );
    } else {
      // If not bookmarked, add the bookmark
      await DBHelper.insertBookmark(shlok);
      _bookMarkedBlogs.add(shlok);
    }

    // Notify listeners to update the UI after bookmarking changes
    notifyListeners();
  }

  bool isBookmarked(BlogSubCategoryData shlok) {
    // Check if the item is already bookmarked
    return _bookMarkedBlogs.any(
      (bookmarked) => bookmarked.title == shlok.title,
    );
  }
}
