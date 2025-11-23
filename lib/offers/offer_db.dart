import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'offer_model.dart';

/// Database helper class for managing purchase offers.
/// Uses SQLite through the sqflite plugin.
class OfferDatabase {
  static final OfferDatabase instance = OfferDatabase._internal();
  Database? _db;

  OfferDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "offers.db");

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customerId TEXT NOT NULL,
            itemId TEXT NOT NULL,
            price REAL NOT NULL,
            date TEXT NOT NULL,
            accepted INTEGER NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Future<int> insertOffer(Offer offer) async {
    final db = await database;
    return db.insert('offers', offer.toMap());
  }

  Future<List<Offer>> getOffers() async {
    final db = await database;
    final rows = await db.query("offers", orderBy: "date DESC");
    return rows.map((e) => Offer.fromMap(e)).toList();
  }

  Future<int> updateOffer(Offer offer) async {
    final db = await database;
    return db.update(
      'offers',
      offer.toMap(),
      where: 'id = ?',
      whereArgs: [offer.id],
    );
  }

  Future<int> deleteOffer(int id) async {
    final db = await database;
    return db.delete(
      'offers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
