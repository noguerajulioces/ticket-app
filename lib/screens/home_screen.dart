import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ticket/screens/layout.dart';
import 'package:ticket/services/database_service.dart';
import 'package:ticket/models/customer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  Customer? _currentCustomer; // Cliente actual
  Customer? _nextCustomer; // Próximo cliente
  bool _isLoading = true;
  late FlutterTts _flutterTts;
  Timer? _pollingTimer; // Timer para el polling

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _loadCustomers();
    _startPolling();
  }

  /// Iniciar el polling para verificar nuevos clientes
  void _startPolling() {
    print("Run polling");
    _pollingTimer = Timer.periodic(
        const Duration(
          seconds: 15,
        ), (timer) {
      _loadCustomers();
    });
  }

  /// Cargar clientes actuales y próximos
  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      await _loadInitialCustomers();
    } catch (e) {
      print('Error loading customers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Carga los clientes actual y próximo usando una única consulta
  Future<void> _loadInitialCustomers() async {
    final currentCustomer = await _dbService.getCurrentCustomers();
    final nextCustomer = await _dbService.getNextCustomers();

    setState(() {
      if (currentCustomer == null && nextCustomer == null) {
        _currentCustomer = null;
        _nextCustomer = null;
      } else if (currentCustomer != null && nextCustomer == null) {
        _currentCustomer = currentCustomer;
        _nextCustomer = null;
      } else {
        _currentCustomer = currentCustomer;
        _nextCustomer = nextCustomer;
      }
    });
  }

  /// Marca al cliente actual como atendido y actualiza el siguiente cliente
  Future<void> _attendCurrentCustomer() async {
    if (_nextCustomer != null && _nextCustomer!.id != null) {
      await _dbService.updateCustomerAttended(_nextCustomer!.id!);
    }
    setState(() {
      _currentCustomer = _nextCustomer;
      _isLoading = true;
    });

    final nextCustomer = await _dbService.getNextCustomers();

    setState(() {
      _nextCustomer = nextCustomer;
      _isLoading = false;
    });
  }

  Future<void> _speakTicketNumber(String? ticketNumber) async {
    if (ticketNumber != null) {
      await _flutterTts.speak("Ticket $ticketNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(
                    16.0), // Padding alrededor de todo el contenido
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección izquierda: Botones con margen y padding
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(16.0), // Padding interno
                        margin: const EdgeInsets.only(right: 10.0),
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildAttendButton(),
                            const SizedBox(height: 20),
                            _buildRecallButton(),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        margin: const EdgeInsets.only(left: 16.0),
                        color: Colors.grey[100],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCurrentTurnInfo(),
                            const SizedBox(height: 20),
                            const Divider(
                              color: Colors
                                  .black, // Puedes cambiar el color del Divider
                              thickness: 1.0, // Grosor de la línea del Divider
                            ),
                            const SizedBox(
                                height:
                                    20), // Espacio entre el Divider y el siguiente texto
                            _buildNextTurnInfo(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Construye el widget que muestra la información del cliente actual
  Widget _buildCurrentTurnInfo() {
    return _currentCustomer != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Turno en Pantalla: ${_currentCustomer!.ticketNumber ?? 'N/A'}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Nombre: ${_currentCustomer!.fullName}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          )
        : const Text('No hay turno actual.');
  }

  /// Construye el widget que muestra la información del próximo turno
  Widget _buildNextTurnInfo() {
    return _nextCustomer != null
        ? Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alineación a la izquierda
            children: [
              Text(
                'Próximo Turno: ${_nextCustomer!.ticketNumber ?? 'N/A'}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Nombre: ${_nextCustomer!.fullName}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          )
        : const Text('Siguiente: No hay.');
  }

  Widget _buildAttendButton() {
    return ElevatedButton(
      onPressed: _nextCustomer == null ? null : _attendCurrentCustomer,
      child: const Text('Atender Próximo'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Esquinas rectas
        ),
      ),
    );
  }

  /// Construye el botón para volver a llamar al cliente actual
  Widget _buildRecallButton() {
    return ElevatedButton(
      onPressed: _currentCustomer?.ticketNumber != null
          ? () {
              // Llamar a la función para actualizar el campo ready_for_sound
              _dbService.updateReadyForSound(_currentCustomer!.id!, 1);
            }
          : null, // Deshabilitar si el ticketNumber es null
      child: Text('Llamar de nuevo ${_currentCustomer?.ticketNumber ?? 'N/A'}'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 40.0,
          horizontal: 40.0,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
