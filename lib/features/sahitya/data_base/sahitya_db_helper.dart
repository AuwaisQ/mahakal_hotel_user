import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/shlokModel.dart';

class VerseDBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shlok.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE IF NOT EXISTS bookmarks(id INTEGER PRIMARY KEY AUTOINCREMENT, verse_data TEXT UNIQUE)",
        );
      },
    );
  }

  static Future<void> insertBookmark(Verse musicModel) async {
    final db = await database;
    try {
      await db.insert(
        'bookmarks',
        {'verse_data': json.encode(musicModel.toJson())},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      print("Error inserting bookmark: $e");
    }
  }

  static Future<void> deleteBookmark(Verse musicModel) async {
    final db = await database;
    try {
      await db.delete(
        'bookmarks',
        where: 'verse_data = ?',
        whereArgs: [json.encode(musicModel.toJson())],
      );
    } catch (e) {
      print("Error deleting bookmark: $e");
    }
  }

  static Future<List<Verse>> getBookmarks() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('bookmarks');
      return List.generate(maps.length, (i) {
        return Verse.fromJson(json.decode(maps[i]['verse_data']));
      });
    } catch (e) {
      print("Error fetching bookmarks: $e");
      return [];
    }
  }
}
