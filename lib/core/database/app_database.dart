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
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE children(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          birthDate TEXT,
          gender INTEGER,
          avatar TEXT,
          level TEXT DEFAULT 'level1'
        )
        ''');
        await db.execute('''
        CREATE TABLE progress(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          childId INTEGER,
          level TEXT,
          letterId INTEGER,
          listened INTEGER DEFAULT 0,
          spoken INTEGER DEFAULT 0,
          written INTEGER DEFAULT 0,
          FOREIGN KEY (childId) REFERENCES children (id)
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE children ADD COLUMN level TEXT DEFAULT 'level1'",
          );
        }
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE progress(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            childId INTEGER,
            level TEXT,
            letterId INTEGER,
            listened INTEGER DEFAULT 0,
            spoken INTEGER DEFAULT 0,
            written INTEGER DEFAULT 0,
            FOREIGN KEY (childId) REFERENCES children (id)
          )
          ''');
        }
      },
    );
  }
}
