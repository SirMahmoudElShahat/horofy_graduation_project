import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();

    return openDatabase(
      join(dbPath, 'horofy.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE children(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          birthDate TEXT,
          gender INTEGER,
          avatar TEXT
        )
        ''');
      },
    );
  }
}
