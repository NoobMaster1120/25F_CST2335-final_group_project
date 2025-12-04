import 'package:flutter/material.dart';
import '../data/offer_dao.dart';
import '../models/offer.dart';
import 'offer_form_page.dart';
import 'offer_detail_panel.dart';

class OfferListPage extends StatefulWidget {
  const OfferListPage({super.key});

  @override
  State<OfferListPage> createState() => _OfferListPageState();
}

class _OfferListPageState extends State<OfferListPage> {
  final dao = OfferDAO();
  List<Offer> offers = [];
  Offer? selectedOffer;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    print("🔄 Loading offers from DB...");
    offers = await dao.getOffers();
    print("📦 Offer count = ${offers.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 650; // Tablet/Desktop layout

        return Scaffold(
          appBar: AppBar(
            title: const Text("Purchase Offers"),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Instructions"),
                      content: const Text(
                        "• Press + to add a new purchase offer.\n"
                            "• Tap on any offer to view or edit.\n"
                            "• Long press to copy or delete.\n"
                            "• Works with SQLite + SharedPreferences.\n",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              print("➕ Navigating to new OfferFormPage...");
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfferFormPage(
                    onSaved: _loadOffers,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),

          body: isWide
              ? Row(
            children: [
              Expanded(child: _buildList(isWide)),
              const VerticalDivider(width: 1),
              Expanded(
                child: selectedOffer == null
                    ? const Center(
                  child: Text(
                    "Select an offer to view details",
                    style: TextStyle(fontSize: 18),
                  ),
                )
                    : OfferDetailPanel(offer: selectedOffer!),
              )
            ],
          )
              : _buildList(isWide),
        );
      },
    );
  }

  Widget _buildList(bool isWide) {
    return ListView.builder(
      itemCount: offers.length,
      itemBuilder: (_, index) {
        final offer = offers[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              "Customer: ${offer.customerId}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Price: \$${offer.price.toStringAsFixed(2)}",
            ),
            onTap: () async {
              print("📌 Selected offer id: ${offer.id}");

              if (isWide) {
                setState(() => selectedOffer = offer);
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OfferFormPage(
                      existing: offer,
                      onSaved: _loadOffers,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
