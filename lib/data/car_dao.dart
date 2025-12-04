import '../data/database.dart';
import '../models/car.dart';

class CarDAO {
  final DatabaseService dbService = DatabaseService.instance;

  Future<int> insertCar(Car car) async {
    final db = await dbService.database;
    return db.insert('cars', car.toMap());
  }

  Future<List<Car>> getCars() async {
    final db = await dbService.database;
    final rows = await db.query("cars", orderBy: "dateAdded DESC");
    return rows.map((e) => Car.fromMap(e)).toList();
  }

  Future<int> updateCar(Car car) async {
    final db = await dbService.database;
    return db.update(
      'cars',
      car.toMap(),
      where: 'id = ?',
      whereArgs: [car.id],
    );
  }

  Future<int> deleteCar(int id) async {
    final db = await dbService.database;
    return db.delete(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}