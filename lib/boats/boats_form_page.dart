import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/boat_dao.dart';
import '../models/boat.dart';

class BoatFormPage extends StatefulWidget {
  final Boat? existing;
  final VoidCallback onSaved;

  const BoatFormPage({
    super.key,
    this.existing,
    required this.onSaved,
  });

  @override
  State<BoatFormPage> createState() => _BoatFormPageState();
}

class _BoatFormPageState extends State<BoatFormPage> {
  final _formKey = GlobalKey<FormState>();
  final dao = BoatDAO();
  final storage = FlutterSecureStorage();

  final yearCtrl = TextEditingController();
  final lengthCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String powerType = "motor";
  bool chinese = false;

  static const lastBoatKey = "last_boat";

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final b = widget.existing!;
      yearCtrl.text = b.yearBuilt.toString();
      lengthCtrl.text = b.length.toString();
      priceCtrl.text = b.price.toString();
      addressCtrl.text = b.address;
      powerType = b.powerType;
    }
  }

  Future<void> copyPrevious() async {
    final jsonStr = await storage.read(key: lastBoatKey);

    if (jsonStr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                chinese ? "没有找到之前的船只" : "No previous boat found")),
      );
      return;
    }

    try {
      final map = jsonDecode(jsonStr);

      yearCtrl.text = map["yearBuilt"]?.toString() ?? "";
      lengthCtrl.text = map["length"]?.toString() ?? "";
      priceCtrl.text = map["price"]?.toString() ?? "";
      addressCtrl.text = map["address"] ?? "";
      powerType = map["powerType"] ?? "motor";

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

  Future<void> saveLast(Boat boat) async {
    try {
      await storage.write(
        key: lastBoatKey,
        value: jsonEncode(boat.toMap()),
      );
    } catch (e) {
      print("Error saving last boat: $e");
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final boat = Boat(
        id: widget.existing?.id,
        yearBuilt: int.parse(yearCtrl.text),
        length: double.parse(lengthCtrl.text),
        powerType: powerType,
        price: double.parse(priceCtrl.text),
        address: addressCtrl.text,
        dateAdded: DateTime.now().toIso8601String(),
      );

      if (boat.id == null) {
        await dao.insertBoat(boat);
      } else {
        await dao.updateBoat(boat);
      }

      await saveLast(boat);

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

  Future<void> deleteBoat() async {
    if (widget.existing == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(chinese ? "确认删除" : "Confirm Delete"),
        content: Text(chinese ? "是否删除此船只?" : "Delete this boat?"),
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
        await dao.deleteBoat(widget.existing!.id!);
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
            ? (editing ? "编辑船只" : "新增船只")
            : (editing ? "Edit Boat" : "New Boat")),
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
                  labelText: chinese ? "建造年份" : "Year Built",
                  hintText: "e.g., 2020",
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final year = int.tryParse(v);
                  if (year == null) return "Enter a valid year";
                  if (year < 1800 || year > DateTime.now().year + 1) {
                    return "Enter a valid year";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: lengthCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "长度 (英尺)" : "Length (feet)",
                  hintText: "e.g., 30.5",
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final length = double.tryParse(v);
                  if (length == null) return "Enter a valid number";
                  if (length <= 0) return "Length must be positive";
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: powerType,
                decoration: InputDecoration(
                  labelText: chinese ? "动力类型" : "Power Type",
                ),
                items: const [
                  DropdownMenuItem(value: "motor", child: Text("Motor")),
                  DropdownMenuItem(value: "sail", child: Text("Sail")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => powerType = value);
                  }
                },
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: priceCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "价格" : "Price",
                  hintText: "e.g., 45000.00",
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
                controller: addressCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "地址" : "Address",
                  hintText: "e.g., 123 Marina Blvd, City",
                ),
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
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
                        onPressed: deleteBoat,
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