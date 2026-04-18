import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mydata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mytable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        str1 TEXT,
        str2 TEXT,
        str3 TEXT,
        str4 TEXT
      )
    ''');
  }

  Future<int> insertData(
      String Mantra, String selectedValue, String Mala, String count) async {
    final db = await instance.database;
    return await db.insert('mytable', {
      'str1': Mantra,
      'str2': selectedValue,
      'str3': Mala,
      'str4': count,
    });
  }

  Future<int> updateData(int id, String Mantra, String selectedValue,
      String Mala, String count) async {
    final db = await instance.database;
    return await db.update(
      'mytable',
      {
        'str1': Mantra,
        'str2': selectedValue,
        'str3': Mala,
        'str4': count,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteData(int id) async {
    final db = await instance.database;
    return await db.delete(
      'mytable',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final db = await instance.database;
    return await db.query('mytable');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
