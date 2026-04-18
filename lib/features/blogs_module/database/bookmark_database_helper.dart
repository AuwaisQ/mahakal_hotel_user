import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/SubCategory_model.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'blogs.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE bookmarks(id INTEGER PRIMARY KEY AUTOINCREMENT, music_model TEXT UNIQUE)",
        );
      },
    );
  }

  static Future<void> insertBookmark(BlogSubCategoryData musicModel) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      {'music_model': json.encode(musicModel.toJson())},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> deleteBookmark(BlogSubCategoryData musicModel) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'music_model = ?',
      whereArgs: [json.encode(musicModel.toJson())],
    );
  }

  static Future<List<BlogSubCategoryData>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks');

    return List.generate(maps.length, (i) {
      return BlogSubCategoryData.fromJson(json.decode(maps[i]['music_model']));
    });
  }
}
