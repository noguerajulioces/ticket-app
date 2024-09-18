import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/customer.dart';
import '../services/usb_printer_service.dart';

class CustomerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final DatabaseService _dbService = DatabaseService();
  final UsbPrinterService printerService =
      UsbPrinterService(); // Instancia del servicio

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
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(8.0),
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Fecha')),
              DataColumn(label: Text('Nombre Completo')),
              DataColumn(label: Text('Tipo de Vehículo')),
              DataColumn(label: Text('Placa del vehículo')),
              DataColumn(label: Text('Ticket Número')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Imprimir')),
            ],
            rows: _customers.map((customer) {
              return DataRow(
                cells: [
                  DataCell(Text(customer.id.toString())),
                  DataCell(
                    Text(customer.formattedCreatedAt ?? 'N/A'),
                  ),
                  DataCell(Text(customer.fullName)),
                  DataCell(Text(customer.vehicleType ?? 'N/A')),
                  DataCell(Text(customer.licensePlate ?? 'N/A')),
                  DataCell(Text(customer.ticketNumber ?? 'N/A')),
                  DataCell(
                    Text(customer.attended == 1 ? 'Atendido' : 'Sin atender'),
                  ),
                  DataCell(
                    ElevatedButton(
                      onPressed: () async {
                        await printerService.findAndPrintViaUsb(context);
                      },
                      child: const Icon(Icons.print),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
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
        title: const Text('Listado de Tickets'),
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
        backgroundColor: const Color(0xFF00A2ED),
        onPressed: _navigateToAddCustomer,
        tooltip: 'Crear nuevo ticket ',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
