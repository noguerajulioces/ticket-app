import 'package:flutter/foundation.dart';
import 'package:mysql_client/mysql_client.dart';
import '../models/customer.dart';

class DatabaseService {
  // Método privado para obtener una conexión
  Future<MySQLConnection> _getConnection() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: '127.0.0.1',
        port: 3306,
        userName: 'noguerajulioces',
        password: 'noguerajulioces',
        databaseName: 'ticket',
      );
      await conn.connect();
      print('Conexión exitosa a la base de datos.');
      return conn;
    } catch (e) {
      print('Error al conectar a la base de datos: $e');
      rethrow;
    }
  }

  // Método para obtener la lista de clientes
  Future<List<Customer>> obtenerClientes() async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();
      print('Conexión establecida: $conn');

      // Ejecutar la consulta
      var result = await conn.execute(
        "SELECT * FROM customers ORDER BY id DESC;",
      );
      print('Consulta ejecutada.');

      List<Customer> customers = [];

      for (final row in result.rows) {
        // Convertir la fila en Map<String, String?>
        Map<String, String?> rowMap = row.assoc();

        // Crear una instancia de Customer
        Customer customer = Customer(
          id: int.parse(rowMap['id'] ?? '0'),
          fullName: rowMap['full_name'] ?? '',
          vehicleType: rowMap['vehicle_type'] ?? '',
          licensePlate: rowMap['license_plate'] ?? '',
          document: rowMap['document'] ?? '',
          company: rowMap['company'] ?? '',
          ticketNumber: rowMap['ticket_number'] ?? '',
        );

        customers.add(customer);
      }

      print('Clientes obtenidos: ${customers.length}');
      return customers;
    } catch (e, stacktrace) {
      print('Error al obtener clientes: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
        print('Conexión cerrada.');
      }
    }
  }

  Future<void> insertarCliente(Customer customer) async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();
      print('Conexión exitosa: $conn');

      // Obtener el último número de ticket de la base de datos
      var result = await conn.execute(
        'SELECT MAX(ticket_number) AS last_ticket FROM customers',
      );

      String lastTicket =
          result.rows.first.assoc()['last_ticket'] ?? 'TKT-0000';
      print('Último número de ticket: $lastTicket');

      // Generar el siguiente número de ticket
      String newTicketNumber = _generarSiguienteTicket(lastTicket);
      print('Nuevo número de ticket generado: $newTicketNumber');

      // Insertar el cliente con el nuevo número de ticket
      var insertResult = await conn.execute(
        'INSERT INTO customers (full_name, vehicle_type, license_plate, document, company, ticket_number) VALUES (:full_name, :vehicle_type, :license_plate, :document, :company, :ticket_number)',
        {
          'full_name': customer.fullName,
          'vehicle_type': customer.vehicleType,
          'license_plate': customer.licensePlate,
          'document': customer.document,
          'company': customer.company,
          'ticket_number': newTicketNumber,
        },
      );

      print('Cliente insertado correctamente con el número de ticket.');
    } catch (e, stacktrace) {
      print('Error al insertar cliente: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
        print('Conexión cerrada.');
      }
    }
  }

// Método para generar el siguiente número de ticket basado en el último
  String _generarSiguienteTicket(String lastTicket) {
    // Extraer el número del formato 'TKT-XXXX'
    int lastTicketNumber = int.parse(lastTicket.split('-')[1]);
    // Incrementar el número
    int newTicketNumber = lastTicketNumber + 1;
    if (kDebugMode) {
      print("el new ticketNumber es ${newTicketNumber}");
    }
    // Formatear el nuevo número de ticket
    return 'TKT-${newTicketNumber.toString().padLeft(4, '0')}';
  }

  // Método para actualizar un cliente
  Future<void> actualizarCliente(Customer customer) async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      await conn.execute(
        'UPDATE customers SET full_name = :full_name, vehicle_type = :vehicle_type, license_plate = :license_plate, document = :document, company = :company WHERE id = :id',
        {
          'full_name': customer.fullName,
          'vehicle_type': customer.vehicleType,
          'license_plate': customer.licensePlate,
          'document': customer.document,
          'company': customer.company,
          'id': customer.id,
        },
      );
    } catch (e, stacktrace) {
      print('Error al actualizar cliente: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  // Método para eliminar un cliente
  Future<void> eliminarCliente(int id) async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      await conn.execute(
        'DELETE FROM customers WHERE id = :id',
        {
          'id': id,
        },
      );
    } catch (e, stacktrace) {
      print('Error al eliminar cliente: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
        print('Conexión cerrada.');
      }
    }
  }
}
