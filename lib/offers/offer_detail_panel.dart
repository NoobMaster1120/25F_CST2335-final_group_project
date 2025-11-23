import 'package:flutter/material.dart';
import 'offer_model.dart';

/// Detail panel used on wide screens (tablet/desktop view).
class OfferDetailPanel extends StatelessWidget {
  final Offer offer;

  const OfferDetailPanel({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Customer ID: ${offer.customerId}", style: TextStyle(fontSize: 20)),
          Text("Item ID: ${offer.itemId}", style: TextStyle(fontSize: 20)),
          Text("Price: \$${offer.price.toStringAsFixed(2)}", style: TextStyle(fontSize: 20)),
          Text("Date: ${offer.date.toString().split(' ')[0]}", style: TextStyle(fontSize: 20)),
          Text("Accepted: ${offer.accepted ? "Yes" : "No"}",
              style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
