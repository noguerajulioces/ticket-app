import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/customer.dart';

/// Screen to display the list of customers in a table format.
class CustomerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Customer> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  /// Loads the list of customers from the database.
  /// Sets the state to display the customers or handle errors.
  Future<void> _loadCustomers() async {
    try {
      final customers = await _dbService.getCustomers();
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading customers: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Builds the table with customer data.
  Widget _buildCustomerTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Full Name')),
            DataColumn(label: Text('Vehicle Type')),
            DataColumn(label: Text('License Plate')),
            DataColumn(label: Text('Ticket Number')),
            DataColumn(label: Text('Attended')),
          ],
          rows: _customers.map((customer) {
            return DataRow(cells: [
              DataCell(Text(customer.id.toString())),
              DataCell(Text(customer.fullName)),
              DataCell(Text(customer.vehicleType ?? 'N/A')),
              DataCell(Text(customer.licensePlate ?? 'N/A')),
              DataCell(Text(customer.ticketNumber ?? 'N/A')),
              DataCell(
                Text(customer.attended == 1 ? 'Atendido' : 'Sin atender'),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  /// Navigates to the 'Add Customer' screen.
  /// Reloads the customer list after returning from the 'Add Customer' screen.
  void _navigateToAddCustomer() {
    Navigator.pushNamed(context, '/register').then((_) => _loadCustomers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? const Center(child: Text('No customers registered.'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildCustomerTable(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCustomer,
        tooltip: 'Add Customer',
        child: const Icon(Icons.add),
      ),
    );
  }
}
