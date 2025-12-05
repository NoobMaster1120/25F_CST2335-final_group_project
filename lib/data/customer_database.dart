import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/customer.dart';

/// Provides access to the local SQLite database for Customer entities.
class CustomerDatabase {
  static final CustomerDatabase _instance = CustomerDatabase._internal();
  factory CustomerDatabase() => _instance;
  CustomerDatabase._internal();

  static Database? _db;

  /// Returns the opened database, creating it if necessary.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'customers.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            address TEXT NOT NULL,
            date_of_birth TEXT NOT NULL,
            driver_license TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Inserts a new customer and returns its generated id.
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return db.insert('customers', customer.toMap());
  }

  /// Returns all customers ordered by last name then first name.
  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final rows = await db.query(
      'customers',
      orderBy: 'last_name ASC, first_name ASC',
    );
    return rows.map(Customer.fromMap).toList();
  }

  /// Updates an existing customer record.
  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  /// Deletes a customer by id.
  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
