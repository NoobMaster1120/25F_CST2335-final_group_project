/// Represents a purchase offer created by the user.
/// This model is stored in the local SQLite database.
class Offer {
  int? id;
  String customerId;
  String itemId;
  double price;
  DateTime date;
  bool accepted;

  Offer({
    this.id,
    required this.customerId,
    required this.itemId,
    required this.price,
    required this.date,
    required this.accepted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'itemId': itemId,
      'price': price,
      'date': date.toIso8601String(),
      'accepted': accepted ? 1 : 0,
    };
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'] as int?,
      customerId: map['customerId'] as String,
      itemId: map['itemId'] as String,
      price: (map['price'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      accepted: map['accepted'] == 1,
    );
  }
}
