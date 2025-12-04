import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/offer_dao.dart';
import '../models/offer.dart';

class OfferFormPage extends StatefulWidget {
  final Offer? existing;
  final VoidCallback onSaved;

  const OfferFormPage({
    super.key,
    this.existing,
    required this.onSaved,
  });

  @override
  State<OfferFormPage> createState() => _OfferFormPageState();
}

class _OfferFormPageState extends State<OfferFormPage> {
  final _formKey = GlobalKey<FormState>();
  final dao = OfferDAO();
  final storage = FlutterSecureStorage(); // Create instance here

  final customerCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  bool chinese = false;
  String status = "Pending";

  static const lastOfferKey = "last_offer";

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final o = widget.existing!;
      customerCtrl.text = o.customerId;
      vehicleCtrl.text = o.vehicleId;
      priceCtrl.text = o.price.toString();
      dateCtrl.text = o.date;
      status = o.status;
    } else {
      // Set default date to today
      final now = DateTime.now();
      dateCtrl.text =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> copyPrevious() async {
    // READ from secure storage
    final jsonStr = await storage.read(key: lastOfferKey);

    if (jsonStr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chinese ? "没有找到之前的报价" : "No previous offer found")),
      );
      return;
    }

    try {
      final map = jsonDecode(jsonStr);

      customerCtrl.text = map["customerId"] ?? "";
      vehicleCtrl.text = map["vehicleId"] ?? "";
      priceCtrl.text = map["price"]?.toString() ?? "";
      dateCtrl.text = map["date"] ?? "";
      status = map["status"] ?? "Pending";

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

  Future<void> saveLast(Offer o) async {
    // WRITE to secure storage
    try {
      await storage.write(
        key: lastOfferKey,
        value: jsonEncode(o.toMap()),
      );
    } catch (e) {
      print("Error saving last offer: $e");
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    final offer = Offer(
      id: widget.existing?.id,
      customerId: customerCtrl.text,
      vehicleId: vehicleCtrl.text,
      price: double.parse(priceCtrl.text),
      date: dateCtrl.text,
      status: status,
    );

    try {
      if (offer.id == null) {
        await dao.insertOffer(offer);
      } else {
        await dao.updateOffer(offer);
      }

      await saveLast(offer);

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

  Future<void> deleteOffer() async {
    if (widget.existing == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(chinese ? "确认删除" : "Confirm Delete"),
        content: Text(chinese ? "是否删除此报价?" : "Delete this offer?"),
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
        await dao.deleteOffer(widget.existing!.id!);
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
            ? (editing ? "编辑报价" : "新增报价")
            : (editing ? "Edit Offer" : "New Offer")),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: customerCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "客户 ID" : "Customer ID",
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: vehicleCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "车辆 ID" : "Vehicle ID",
                ),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: priceCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "报价" : "Price",
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  final value = double.tryParse(v);
                  if (value == null) return "Enter a valid number";
                  if (value <= 0) return "Price must be positive";
                  return null;
                },
              ),
              TextFormField(
                controller: dateCtrl,
                decoration: InputDecoration(
                  labelText: chinese ? "日期 YYYY-MM-DD" : "Date YYYY-MM-DD",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Required";
                  // Simple date format validation
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!regex.hasMatch(v)) return "Use YYYY-MM-DD format";
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                  labelText: chinese ? "状态" : "Status",
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Pending",
                    child: Text("Pending"),
                  ),
                  DropdownMenuItem(
                    value: "Accepted",
                    child: Text("Accepted"),
                  ),
                  DropdownMenuItem(
                    value: "Rejected",
                    child: Text("Rejected"),
                  ),
                  DropdownMenuItem(
                    value: "Expired",
                    child: Text("Expired"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => status = value);
                  }
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
                        onPressed: deleteOffer,
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
