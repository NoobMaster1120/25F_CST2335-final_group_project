/// Represents a customer in the system.
class Customer {
  /// Database primary key. May be null for new customers.
  final int? id;

  /// Customer's first name.
  final String firstName;

  /// Customer's last name.
  final String lastName;

  /// Customer's street address.
  final String address;

  /// Customer's date of birth, stored as ISO-8601 string (YYYY-MM-DD).
  final String dateOfBirth;

  /// Customer's driver license number.
  final String driverLicense;

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.dateOfBirth,
    required this.driverLicense,
  });

  /// Returns a copy of this customer with updated fields.
  Customer copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? address,
    String? dateOfBirth,
    String? driverLicense,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      driverLicense: driverLicense ?? this.driverLicense,
    );
  }

  /// Converts this customer into a Map suitable for SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'address': address,
      'date_of_birth': dateOfBirth,
      'driver_license': driverLicense,
    };
  }

  /// Creates a customer from a SQLite row.
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      address: map['address'] as String,
      dateOfBirth: map['date_of_birth'] as String,
      driverLicense: map['driver_license'] as String,
    );
  }
}
