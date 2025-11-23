import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offer_db.dart';
import 'offer_model.dart';

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
  final db = OfferDatabase.instance;

  final customerCtrl = TextEditingController();
  final itemCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  bool accepted = true;
  bool chinese = false;

  static const lastOfferKey = "last_offer";

  @override
  void initState() {
    super.initState();

    if (widget.existing != null) {
      final o = widget.existing!;
      customerCtrl.text = o.customerId;
      itemCtrl.text = o.itemId;
      priceCtrl.text = o.price.toString();
      dateCtrl.text = o.date.toIso8601String().split('T')[0];
      accepted = o.accepted;
    }
  }

  Future<void> copyPrevious() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(lastOfferKey);

    if (jsonStr == null) return;

    final map = jsonDecode(jsonStr);

    customerCtrl.text = map["customerId"];
    itemCtrl.text = map["itemId"];
    priceCtrl.text = map["price"].toString();
    dateCtrl.text = map["date"];
    accepted = map["accepted"] == 1;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(chinese ? "已复制上一个" : "Copied previous")),
    );
  }

  Future<void> saveLast(Offer o) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(lastOfferKey, jsonEncode(o.toMap()));
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    final offer = Offer(
      id: widget.existing?.id,
      customerId: customerCtrl.text,
      itemId: itemCtrl.text,
      price: double.parse(priceCtrl.text),
      date: DateTime.parse(dateCtrl.text),
      accepted: accepted,
    );

    if (offer.id == null) {
      await db.insertOffer(offer);
    } else {
      await db.updateOffer(offer);
    }

    await saveLast(offer);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(chinese ? "保存成功" : "Saved")),
    );

    widget.onSaved();
    Navigator.pop(context);
  }

  Future<void> deleteOffer() async {
    if (widget.existing == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(chinese ? "确认删除" : "Confirm Delete"),
        content: Text(chinese ? "是否删除此报价?" : "Delete this offer?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Yes")),
        ],
      ),
    );

    if (ok == true) {
      await db.deleteOffer(widget.existing!.id!);
      widget.onSaved();
      Navigator.pop(context);
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
            icon: Icon(Icons.language),
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

              TextFormField(
                controller: customerCtrl,
                decoration: InputDecoration(labelText: chinese ? "客户 ID" : "Customer ID"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: itemCtrl,
                decoration: InputDecoration(labelText: chinese ? "物品 ID" : "Item ID"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: priceCtrl,
                decoration:
                    InputDecoration(labelText: chinese ? "报价" : "Price"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: dateCtrl,
                decoration:
                    InputDecoration(labelText: chinese ? "日期 YYYY-MM-DD" : "Date YYYY-MM-DD"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              SwitchListTile(
                title: Text(chinese ? "接受" : "Accepted"),
                value: accepted,
                onChanged: (v) => setState(() => accepted = v),
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: save,
                      child: Text(chinese ? "保存" : (editing ? "Update" : "Submit")),
                    ),
                  ),

                  if (editing) SizedBox(width: 20),

                  if (editing)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: deleteOffer,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
