import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/customer.dart';

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
    _cargarClientes();
  }

  Future<void> _cargarClientes() async {
    try {
      List<Customer> customers = await _dbService.obtenerClientes();
      print("Lista de customers: ${customers}");
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar clientes: $e');
      setState(() {
        _isLoading = false;
      });
      // Opcional: mostrar mensaje de error al usuario
    }
  }

  void _navegarAAgregarCliente() {
    Navigator.pushNamed(context, '/add_customer').then((_) {
      _cargarClientes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Clientes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _customers.isEmpty
              ? const Center(child: Text('No hay clientes registrados.'))
              : ListView.builder(
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    Customer customer = _customers[index];
                    return ListTile(
                      title: Text(customer.fullName),
                      subtitle: Text(
                          'Vehículo: ${customer.vehicleType} - ${customer.ticketNumber}'),
                      onTap: () {
                        // Navegar a detalles o editar cliente
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarAAgregarCliente,
        tooltip: 'Agregar Cliente',
        child: const Icon(Icons.add),
      ),
    );
  }
}
