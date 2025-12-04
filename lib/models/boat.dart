class Boat {
  int? id;
  int yearBuilt;
  double length;
  String powerType; // "sail" or "motor"
  double price;
  String address;
  String dateAdded;

  Boat({
    this.id,
    required this.yearBuilt,
    required this.length,
    required this.powerType,
    required this.price,
    required this.address,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'yearBuilt': yearBuilt,
      'length': length,
      'powerType': powerType,
      'price': price,
      'address': address,
      'dateAdded': dateAdded,
    };
  }

  static Boat fromMap(Map<String, dynamic> map) {
    return Boat(
      id: map['id'],
      yearBuilt: map['yearBuilt'],
      length: map['length'],
      powerType: map['powerType'],
      price: map['price'],
      address: map['address'],
      dateAdded: map['dateAdded'],
    );
  }
}