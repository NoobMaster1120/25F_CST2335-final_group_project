
class Offer {
  int? id;
  String customerId;
  String vehicleId;
  double price;
  String date;
  String status;

  Offer({
    this.id,
    required this.customerId,
    required this.vehicleId,
    required this.price,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'price': price,
      'date': date,
      'status': status,
    };
  }

  static Offer fromMap(Map<String, dynamic> map) {
    return Offer(
      id: map['id'],
      customerId: map['customerId'],
      vehicleId: map['vehicleId'],
      price: map['price'],
      date: map['date'],
      status: map['status'],
    );
  }
}
