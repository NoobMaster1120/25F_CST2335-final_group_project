
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfferDatabase {
  static final OfferDatabase instance = OfferDatabase._init();
  static Database? _database;

  OfferDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('offers.db');
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
  }
}
