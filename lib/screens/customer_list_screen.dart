import 'package:flutter/material.dart';
import 'package:ticket/models/customer.dart';

class CustomerListScreen extends StatelessWidget {
  // Lista de clientes simulada (puedes reemplazarla con datos de tu base de datos o API)
  final List<Customer> customers = [
    Customer(
      fullName: 'John Doe',
      vehicleType: 'Sedan',
      licensePlate: 'ABC123',
      document: '12345678',
      company: 'ABC Corp',
    ),
    Customer(
      fullName: 'Jane Smith',
      vehicleType: 'SUV',
      licensePlate: 'XYZ987',
      document: '87654321',
      company: 'XYZ Inc',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Customers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Full Name')),
              DataColumn(label: Text('Vehicle Type')),
              DataColumn(label: Text('License Plate')),
              DataColumn(label: Text('Document')),
              DataColumn(label: Text('Company')),
            ],
            rows: customers.map((customer) {
              return DataRow(cells: [
                DataCell(Text(customer.fullName)),
                DataCell(Text(customer.vehicleType)),
                DataCell(Text(customer.licensePlate)),
                DataCell(Text(customer.document)),
                DataCell(Text(customer.company)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
