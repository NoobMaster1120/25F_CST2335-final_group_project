import 'package:flutter/material.dart';
import 'home_page.dart';

/// Entry point of the entire Final Project Application.
/// This loads HomePage, which contains 4 buttons to enter each module.
void main() {
  runApp(const FinalProjectApp());
}

class FinalProjectApp extends StatelessWidget {
  const FinalProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CST2335 Final Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
