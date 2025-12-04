import '../data/database.dart';
import '../models/offer.dart';

class OfferDAO {
  final DatabaseService dbService = DatabaseService.instance;

  Future<int> insertOffer(Offer offer) async {
    final db = await dbService.database;
    return db.insert('offers', offer.toMap());
  }

  Future<List<Offer>> getOffers() async {
    final db = await dbService.database;
    final rows = await db.query("offers", orderBy: "date DESC");
    return rows.map((e) => Offer.fromMap(e)).toList();
  }

  Future<int> updateOffer(Offer offer) async {
    final db = await dbService.database;
    return db.update(
      'offers',
      offer.toMap(),
      where: 'id = ?',
      whereArgs: [offer.id],
    );
  }

  Future<int> deleteOffer(int id) async {
    final db = await dbService.database;
    return db.delete(
      'offers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}