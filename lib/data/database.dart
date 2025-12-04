import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('final_project.db');
    return _database!;
  }

  Future<Database> _initDB(String file) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, file);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // create offers table
    await db.execute('''
      CREATE TABLE offers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId TEXT,
        vehicleId TEXT,
        price REAL,
        date TEXT,
        status TEXT
      )
    ''');

    // create cars table
    await db.execute('''
      CREATE TABLE cars(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        price REAL NOT NULL,
        kilometers INTEGER NOT NULL,
        dateAdded TEXT NOT NULL
      )
    ''');

    // create boats table
    await db.execute('''
      CREATE TABLE boats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        yearBuilt INTEGER NOT NULL,
        length REAL NOT NULL,
        powerType TEXT NOT NULL,
        price REAL NOT NULL,
        address TEXT NOT NULL,
        dateAdded TEXT NOT NULL
      )
    ''');
  }

  // close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
