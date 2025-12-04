import '../data/database.dart';
import '../models/boat.dart';

class BoatDAO {
  final DatabaseService dbService = DatabaseService.instance;

  Future<int> insertBoat(Boat boat) async {
    final db = await dbService.database;
    return db.insert('boats', boat.toMap());
  }

  Future<List<Boat>> getBoats() async {
    final db = await dbService.database;
    final rows = await db.query("boats", orderBy: "dateAdded DESC");
    return rows.map((e) => Boat.fromMap(e)).toList();
  }

  Future<int> updateBoat(Boat boat) async {
    final db = await dbService.database;
    return db.update(
      'boats',
      boat.toMap(),
      where: 'id = ?',
      whereArgs: [boat.id],
    );
  }

  Future<int> deleteBoat(int id) async {
    final db = await dbService.database;
    return db.delete(
      'boats',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}