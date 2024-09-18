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
      if (_currentCustomer == null) {
        // Si no hay cliente actual, cargar el cliente más reciente y el siguiente
        await _loadInitialCustomers();
      } else {
        // Si ya hay un cliente actual, marcarlo como atendido y cargar el siguiente
        await _attendCurrentCustomer();
      }
    } catch (e) {
      print('Error loading customers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Carga los clientes actual y próximo usando una única consulta
  Future<void> _loadInitialCustomers() async {
    // Usar el método getCurrentAndNextCustomers para obtener ambos clientes
    final customers = await _dbService.getCurrentAndNextCustomers();

    setState(() {
      if (customers.isNotEmpty) {
        _currentCustomer = customers.length > 0 ? customers[0] : null;
        _nextCustomer = customers.length > 1 ? customers[1] : null;
      }
    });
  }

  /// Marca al cliente actual como atendido y actualiza el siguiente cliente
  Future<void> _attendCurrentCustomer() async {
    // Marcar al cliente actual como atendido
    await _dbService.updateCustomerAttended(_currentCustomer!.id!);

    setState(() {
      // Mover el próximo cliente como el actual
      _currentCustomer = _nextCustomer;
      _isLoading =
          true; // Mostrar el cargador mientras buscamos el siguiente cliente
    });

    // Buscar el próximo cliente desde la base de datos
    final customers = await _dbService.getCurrentAndNextCustomers();
    setState(() {
      _nextCustomer = customers.length > 1 ? customers[1] : null;
    });
  }

  /// Método para reproducir el número de ticket usando FlutterTTS
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
                'Turno Actual: ${_currentCustomer!.fullName}',
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
      onPressed: _nextCustomer?.ticketNumber != null
          ? _loadCustomers
          : null, // Deshabilitar si el ticketNumber es null
      child: Text('Atender a ${_nextCustomer?.ticketNumber ?? 'N/A'}'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
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
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
