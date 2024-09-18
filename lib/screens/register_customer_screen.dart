import 'dart:math';

import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/database_service.dart';

class RegisterCustomerScreen extends StatefulWidget {
  @override
  _RegisterCustomerScreenState createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends State<RegisterCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _fullName;
  String? _vehicleType;
  String? _licensePlate;
  String? _document;
  String? _company;
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();

      // Create a new customer
      Customer newCustomer = Customer(
        fullName: _fullName!,
        vehicleType: _vehicleType,
        licensePlate: _licensePlate,
        document: _document!,
        company: _company,
      );

      try {
        DatabaseService dbService = DatabaseService();

        await dbService.insertCustomer(newCustomer);

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cliente registrado exitosamente!'),
          ),
        );

        // Pop the screen and return a result indicating success
        Navigator.pushReplacementNamed(
            context, '/customer_list'); // Navigating to home
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar el cliente: $e'),
          ),
        );
      }
    }
  }

// Método para generar un número de ticket (puede ser secuencial o basado en otra lógica)
  String _generarNumeroDeTicket() {
    // Ejemplo: Generar un número de ticket simple, podrías modificar esta lógica
    int ticketBase = 1000; // Lógica simple de ejemplo
    return 'TKT-${ticketBase + Random().nextInt(1000)}'; // Ejemplo de número de ticket
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Cliente'),
      ),
      body: Center(
        child: SingleChildScrollView(
          // Para evitar problemas de desbordamiento
          child: Container(
            margin: const EdgeInsets.all(32.0),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Nombre Completo'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre completo';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _fullName = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Tipo de Vehículo'),
                    onSaved: (value) {
                      _vehicleType = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Placa'),
                    onSaved: (value) {
                      _licensePlate = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Documento'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el documento';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _document = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Empresa'),
                    onSaved: (value) {
                      _company = value;
                    },
                  ),
                  const SizedBox(height: 32.0),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save), // Ícono de guardar
                              SizedBox(width: 8.0),
                              Text('Registrar'),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
