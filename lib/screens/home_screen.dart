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

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _loadCustomers(); // Cargar clientes al iniciar
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCurrentTurnInfo(),
                  const SizedBox(height: 20),
                  _buildNextTurnInfo(),
                  const SizedBox(height: 20),
                  _buildAttendButton(),
                  const SizedBox(height: 20),
                  _buildRecallButton(),
                ],
              ),
      ),
    );
  }

  /// Construye el widget que muestra la información del cliente actual
  Widget _buildCurrentTurnInfo() {
    return _currentCustomer != null
        ? Column(
            children: [
              Text(
                'Turno en Pantalla: ${_currentCustomer!.fullName}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Número de Turno: ${_currentCustomer!.ticketNumber ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          )
        : const Text('No hay turno actual.');
  }

  /// Construye el widget que muestra la información del próximo turno
  Widget _buildNextTurnInfo() {
    return _nextCustomer != null
        ? Column(
            children: [
              Text(
                'Próximo Turno: ${_nextCustomer!.fullName}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                'Número de Turno: ${_nextCustomer!.ticketNumber ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          )
        : const Text('No hay más turnos.');
  }

  Widget _buildAttendButton() {
    return ElevatedButton(
      onPressed: _attendCurrentCustomer,
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
              _speakTicketNumber(_currentCustomer!.ticketNumber!);
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
          )),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
