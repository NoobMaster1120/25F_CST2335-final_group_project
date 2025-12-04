import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/car_dao.dart';
import '../models/car.dart';

class CarFormPage extends StatefulWidget {
  final Car? existing;
  final VoidCallback onSaved;

  const CarFormPage({
    super.key,
    this.existing,
    required this.onSaved,
  });

  @override
  State<CarFormPage> createState() => _CarFormPageState();
}

class _CarFormPageState extends State<CarFormPage> {
  final _formKey = GlobalKey<FormState>();
  final dao = CarDAO();
  final storage = FlutterSecureStorage();

  final yearCtrl = TextEditingController();
  final makeCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final kilometersCtrl = TextEditingController();

  bool chinese = false;

  static const lastCarKey = "last_car";

  @override
  void initState() {
  super.initState();

  if (widget.existing != null) {
    final c = widget.existing!;
    yearCtrl.text = c.year.toString();
    makeCtrl.text = c.make;
    modelCtrl.text = c.model;
    priceCtrl.text = c.price.toString();
    kilometersCtrl.text = c.kilometers.toString();
  } else {
    // sets default values for new cars
    final now = DateTime.now();
    
    // default year: current year
    yearCtrl.text = now.year.toString();
    
    // default make: empty
    makeCtrl.text = "";
    
    // default model: empty
    modelCtrl.text = "";
    
    // default price: 0.0
    priceCtrl.text = "0.0";
    
    // default kilometers: 0
    kilometersCtrl.text = "0";
  }
}

  Future<void> copyPrevious() async {
    final jsonStr = await storage.read(key: lastCarKey);

    if (jsonStr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                chinese ? "没有找到之前的汽车" : "No previous car found")),
      );
      return;
    }

    try {
      final map = jsonDecode(jsonStr);

      yearCtrl.text = map["year"]?.toString() ?? "";
      makeCtrl.text = map["make"] ?? "";
      modelCtrl.text = map["model"] ?? "";
      priceCtrl.text = map["price"]?.toString() ?? "";
      kilometersCtrl.text = map["kilometers"]?.toString() ?? "";

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chinese ? "已复制上一个" : "Copied previous")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chinese ? "复制失败" : "Failed to copy: $e")),
      );
    }
  }

  Future<void> saveLast(Car car) async {
    try {
      await storage.write(
        key: lastCarKey,
        value: jsonEncode(car.toMap()),
      );
    } catch (e) {
      print("Error saving last car: $e");
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final car = Car(
        id: widget.existing?.id,
        year: int.parse(yearCtrl.text),
        make: makeCtrl.text,
        model: modelCtrl.text,
        price: double.parse(priceCtrl.text),
        kilometers: int.parse(kilometersCtrl.text),
        dateAdded: DateTime.now().toIso8601String(),
      );

      if (car.id == null) {
        await dao.insertCar(car);
      } else {
        await dao.updateCar(car);
      }

      await saveLast(car);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chinese ? "保存成功" : "Saved")),
      );

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chinese ? "保存失败: $e" : "Save failed: $e")),
      );
    }
  }

  Future<void> deleteCar() async {
    if (widget.existing == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(chinese ? "确认删除" : "Confirm Delete"),
        content: Text(chinese ? "是否删除此汽车?" : "Delete this car?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await dao.deleteCar(widget.existing!.id!);
        widget.onSaved();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(chinese ? "删除失败" : "Delete failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(chinese
            ? (editing ? "编辑汽车" : "新增汽车")
            : (editing ? "Edit Car" : "New Car")),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => setState(() => chinese = !chinese),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: copyPrevious,
                child: Text(chinese ? "复制上一个" : "Copy previous"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: yearCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "制造年份" : "Year of Manufacture",
                  hintText: "e.g., 2023",
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final year = int.tryParse(v);
                  if (year == null) return "Enter a valid year";
                  if (year < 1886 || year > DateTime.now().year + 1) {
                    return "Enter a valid year (1886-${DateTime.now().year + 1})";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: makeCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "品牌" : "Make",
                  hintText: "e.g., Toyota, Tesla, Volkswagen",
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: modelCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "型号" : "Model",
                  hintText: "e.g., Corolla, Jetta, Model 3",
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: priceCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "价格" : "Price",
                  hintText: "e.g., 25000.00",
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final price = double.tryParse(v);
                  if (price == null) return "Enter a valid number";
                  if (price <= 0) return "Price must be positive";
                  return null;
                },
              ),
              TextFormField(
                controller: kilometersCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "公里数" : "Kilometers Driven",
                  hintText: "e.g., 50000",
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final km = int.tryParse(v);
                  if (km == null) return "Enter a valid number";
                  if (km < 0) return "Kilometers cannot be negative";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: save,
                      child: Text(
                        chinese ? "保存" : (editing ? "Update" : "Submit"),
                      ),
                    ),
                  ),
                  if (editing) const SizedBox(width: 20),
                  if (editing)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: deleteCar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(chinese ? "删除" : "Delete"),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}