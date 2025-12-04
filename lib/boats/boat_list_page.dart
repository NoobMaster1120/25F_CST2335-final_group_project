import 'package:flutter/material.dart';
import '../data/boat_dao.dart';
import '../models/boat.dart';
import 'boats_form_page.dart';

class BoatListPage extends StatefulWidget {
  const BoatListPage({super.key});

  @override
  State<BoatListPage> createState() => _BoatListPageState();
}

class _BoatListPageState extends State<BoatListPage> {
  final dao = BoatDAO();
  List<Boat> boats = [];
  Boat? selectedBoat;

  @override
  void initState() {
    super.initState();
    _loadBoats();
  }

  Future<void> _loadBoats() async {
    print("🔄 Loading boats from DB...");
    boats = await dao.getBoats();
    print("📦 Boat count = ${boats.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 650;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Boats for Sale"),
            actions: [
            IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
            showDialog(
            context: context,
            builder: (_) => AlertDialog( 
            title: const Text("Instructions"),
            content: const Text(
                "• Press + to add a new boat for sale.\n"
              "• Tap on any boat to view or edit.\n"
              "• Use 'Copy previous' to copy last boat's details.\n"
              "• Works with SQLite + EncryptedSharedPreferences.\n",
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
              print("➕ Navigating to new BoatFormPage...");
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BoatFormPage(
                    onSaved: _loadBoats,
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
                      child: selectedBoat == null
                          ? const Center(
                              child: Text(
                                "Select a boat to view details",
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : _buildBoatDetailPanel(selectedBoat!),
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
      itemCount: boats.length,
      itemBuilder: (_, index) {
        final boat = boats[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              "${boat.yearBuilt} ${boat.powerType == 'motor' ? 'Motor' : 'Sail'} Boat",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Length: ${boat.length} ft"),
                Text("Price: \$${boat.price.toStringAsFixed(2)}"),
                Text("Address: ${boat.address}"),
              ],
            ),
            onTap: () async {
              print("📌 Selected boat id: ${boat.id}");

              if (isWide) {
                setState(() => selectedBoat = boat);
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BoatFormPage(
                      existing: boat,
                      onSaved: _loadBoats,
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

  Widget _buildBoatDetailPanel(Boat boat) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Year Built: ${boat.yearBuilt}",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Length: ${boat.length} ft",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Power Type: ${boat.powerType}",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Price: \$${boat.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Address: ${boat.address}",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Added: ${boat.dateAdded}",
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}