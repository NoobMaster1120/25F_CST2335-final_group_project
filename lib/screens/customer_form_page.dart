import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../data/customer_database.dart';
import '../data/customer_prefs.dart';

/// Displays a form to create or edit a [Customer].
class CustomerFormPage extends StatefulWidget {
  /// Existing customer to edit, or null to create a new one.
  final Customer? existing;

  /// If true, the form fields are read-only and no Save button is shown.
  final bool readOnly;

  const CustomerFormPage({
    super.key,
    this.existing,
    this.readOnly = false,
  });

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _db = CustomerDatabase();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _dobController;
  late final TextEditingController _licenseController;

  bool _isNewCustomer = true;
  bool _loadingPrefs = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _addressController = TextEditingController();
    _dobController = TextEditingController();
    _licenseController = TextEditingController();

    _isNewCustomer = widget.existing == null;

    if (widget.existing != null) {
      // Editing existing customer.
      _firstNameController.text = widget.existing!.firstName;
      _lastNameController.text = widget.existing!.lastName;
      _addressController.text = widget.existing!.address;
      _dobController.text = widget.existing!.dateOfBirth;
      _licenseController.text = widget.existing!.driverLicense;
    } else {
      // New customer: ask if they want to copy previous one.
      _askCopyPreviousCustomer();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _askCopyPreviousCustomer() async {
    setState(() => _loadingPrefs = true);
    final last = await CustomerPrefs.loadLastCustomer();
    setState(() => _loadingPrefs = false);

    if (!mounted) return;

    if (last == null) {
      // No previous customer saved – nothing to ask.
      return;
    }

    final shouldCopy = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy previous customer?'),
        content: const Text(
          'We found a previously entered customer. '
              'Do you want to copy their information into this form?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Start blank'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Copy previous'),
          ),
        ],
      ),
    );

    if (shouldCopy == true && last != null && mounted) {
      _firstNameController.text = last['firstName'] ?? '';
      _lastNameController.text = last['lastName'] ?? '';
      _addressController.text = last['address'] ?? '';
      _dobController.text = last['dateOfBirth'] ?? '';
      _licenseController.text = last['driverLicense'] ?? '';
    }
  }

  Future<void> _pickDate() async {
    if (widget.readOnly) return;

    final now = DateTime.now();
    final initialDate = now.subtract(const Duration(days: 365 * 18)); // ~18 years ago
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      _dobController.text = picked.toIso8601String().split('T').first; // YYYY-MM-DD
    }
  }

  Future<void> _save() async {
    if (widget.readOnly) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final customer = Customer(
      id: widget.existing?.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      address: _addressController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
      driverLicense: _licenseController.text.trim(),
    );

    if (_isNewCustomer) {
      await _db.insertCustomer(customer);
    } else {
      await _db.updateCustomer(customer);
    }

    // Save as "last customer" for copy-next-time feature.
    await CustomerPrefs.saveLastCustomer(
      firstName: customer.firstName,
      lastName: customer.lastName,
      address: customer.address,
      dateOfBirth: customer.dateOfBirth,
      driverLicense: customer.driverLicense,
    );

    if (!mounted) return;
    Navigator.pop(context, true); // true = saved
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.readOnly
        ? 'Customer details'
        : _isNewCustomer
        ? 'Add customer'
        : 'Edit customer';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _firstNameController,
                readOnly: widget.readOnly,
                decoration: _inputDecoration('First name', icon: Icons.person),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'First name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                readOnly: widget.readOnly,
                decoration: _inputDecoration('Last name', icon: Icons.person_outline),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Last name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                readOnly: widget.readOnly,
                decoration: _inputDecoration('Address', icon: Icons.home),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Address is required' : null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: widget.readOnly ? null : _pickDate,
                child: AbsorbPointer(
                  absorbing: true,
                  child: TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: _inputDecoration(
                      'Date of birth (YYYY-MM-DD)',
                      icon: Icons.cake,
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Date of birth is required'
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _licenseController,
                readOnly: widget.readOnly,
                decoration: _inputDecoration('Driver\'s license #', icon: Icons.badge),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Driver\'s license is required'
                    : null,
              ),
              const SizedBox(height: 24),
              if (!widget.readOnly)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save customer'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
