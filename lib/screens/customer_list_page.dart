import 'package:flutter/material.dart';
import '../data/customer_database.dart';
import '../models/customer.dart';
import 'customer_form_page.dart';

/// Shows the list of customers and handles navigation to the customer form.
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final _db = CustomerDatabase();
  List<Customer> _customers = [];
  Customer? _selectedCustomer; // for tablet/desktop detail view

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final list = await _db.getAllCustomers();
    setState(() => _customers = list);
  }

  void _openForm({Customer? customer}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerFormPage(existing: customer),
      ),
    );

    if (saved == true) {
      await _loadCustomers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer saved')),
      );
    }
  }

  void _confirmDelete(Customer customer) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete customer'),
        content: Text('Are you sure you want to delete ${customer.firstName} ${customer.lastName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _db.deleteCustomer(customer.id!);
      await _loadCustomers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted')),
      );
    }
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('How to use Customers'),
        content: const Text(
          'Use the + button to add a new customer. Tap a customer to edit details. '
              'Long-press (or use the delete icon) to remove a customer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    final listWidget = ListView.builder(
      itemCount: _customers.length,
      itemBuilder: (ctx, index) {
        final customer = _customers[index];
        return ListTile(
          title: Text('${customer.firstName} ${customer.lastName}'),
          subtitle: Text(customer.address),
          onTap: () {
            if (isWide) {
              setState(() => _selectedCustomer = customer);
            } else {
              _openForm(customer: customer);
            }
          },
          onLongPress: () => _confirmDelete(customer),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(customer),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: isWide
          ? Row(
        children: [
          Expanded(child: listWidget),
          Expanded(
            child: _selectedCustomer == null
                ? const Center(child: Text('Select a customer'))
                : CustomerFormPage(existing: _selectedCustomer!, readOnly: true),
          ),
        ],
      )
          : listWidget,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
