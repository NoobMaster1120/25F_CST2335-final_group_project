import 'package:flutter/material.dart';
import '../data/car_dao.dart';
import '../models/car.dart';
import 'car_form_page.dart';

class CarListPage extends StatefulWidget {
  const CarListPage({super.key});

  @override
  State<CarListPage> createState() => _CarListPageState();
}

class _CarListPageState extends State<CarListPage> {
  final dao = CarDAO();
  List<Car> cars = [];
  Car? selectedCar;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    print("🔄 Loading cars from DB...");
    cars = await dao.getCars();
    print("📦 Car count = ${cars.length}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isWide = constraints.maxWidth > 650;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Cars for Sale"),
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog( 
                      title: const Text("Instructions"),
                      content: const Text(
                        "• Press + to add a new car for sale.\n"
                        "• Tap on any car to view or edit.\n"
                        "• Use 'Copy previous' to copy last car's details.\n"
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
              print("➕ Navigating to new CarFormPage...");
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CarFormPage(
                    onSaved: _loadCars,
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
                      child: selectedCar == null
                          ? const Center(
                              child: Text(
                                "Select a car to view details",
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : _buildCarDetailPanel(selectedCar!),
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
      itemCount: cars.length,
      itemBuilder: (_, index) {
        final car = cars[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              "${car.year} ${car.make} ${car.model}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Price: \$${car.price.toStringAsFixed(2)}"),
                Text("Kilometers: ${car.kilometers} km"),
              ],
            ),
            onTap: () async {
              print("📌 Selected car id: ${car.id}");

              if (isWide) {
                setState(() => selectedCar = car);
              } else {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarFormPage(
                      existing: car,
                      onSaved: _loadCars,
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

  Widget _buildCarDetailPanel(Car car) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Year: ${car.year}", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Make: ${car.make}", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Model: ${car.model}", style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Price: \$${car.price.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Kilometers: ${car.kilometers} km",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text("Added: ${car.dateAdded}",
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}