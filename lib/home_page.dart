import 'package:flutter/material.dart';
import 'offers/offer_list_page.dart';
import 'cars/car_list_page.dart';
import 'boats/boat_list_page.dart';

/// Main landing page for the CST2335 Final Project.
/// Contains 4 buttons that navigate to each team member's module.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool chinese = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chinese ? "最终项目首页" : "Final Project Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => setState(() => chinese = !chinese),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton(
              context,
              chinese ? "客户管理" : "Customer List",
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("This module will be built by teammate.")),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildButton(
              context,
              chinese ? "车辆管理" : "Cars for Sale",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CarListPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildButton(
              context,
              chinese ? "船只管理" : "Boats for Sale",
              () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BoatListPage()),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildButton(
              context,
              chinese ? "购买报价" : "Purchase Offers",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OfferListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onTap) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
