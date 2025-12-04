import 'package:flutter/material.dart';
import '../models/offer.dart';

/// detail panel used on wide screens (tablet/desktop view).
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
          Text("Customer ID: ${offer.customerId}", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Vehicle ID: ${offer.vehicleId}", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Price: \$${offer.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Date: ${offer.date}", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Status: ${offer.status}", style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
