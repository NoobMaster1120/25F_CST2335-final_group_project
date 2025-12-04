class Car {
  int? id;
  int year;
  String make;
  String model;
  double price;
  int kilometers;
  String dateAdded;

  Car({
    this.id,
    required this.year,
    required this.make,
    required this.model,
    required this.price,
    required this.kilometers,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'make': make,
      'model': model,
      'price': price,
      'kilometers': kilometers,
      'dateAdded': dateAdded,
    };
  }

  static Car fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'],
      year: map['year'],
      make: map['make'],
      model: map['model'],
      price: map['price'],
      kilometers: map['kilometers'],
      dateAdded: map['dateAdded'],
    );
  }
}