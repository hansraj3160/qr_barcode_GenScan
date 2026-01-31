import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'qr_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, type TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)",
        );
      },
    );
  }

  Future<void> insertHistory(String content, String type) async {
    final db = await database;
    await db.insert('history', {'content': content, 'type': type});
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query('history', orderBy: 'timestamp DESC');
  }
  // ...existing code...

  Future<void> deleteHistory(String content) async {
    final db = await database;
    await db.delete(
      'history',
      where: 'content = ?',
      whereArgs: [content],
    );
  }

// ...existing code...
}