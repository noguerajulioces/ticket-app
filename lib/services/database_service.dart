import 'package:flutter/foundation.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';

/// Service for interacting with the MySQL database, handling customer CRUD operations.
class DatabaseService {
  /// Private method to establish a MySQL connection.
  ///
  /// Returns an open [MySQLConnection] or throws an error if the connection fails.
  Future<MySQLConnection> _getConnection() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Cargar la configuración de conexión desde SharedPreferences
      String host = prefs.getString('dbHost') ?? '127.0.0.1';
      int port = int.parse(prefs.getString('dbPort') ?? '3306');
      String userName = prefs.getString('dbUserName') ?? '';
      String password = prefs.getString('dbPassword') ?? '';
      String databaseName = prefs.getString('dbName') ?? '';

      final conn = await MySQLConnection.createConnection(
        host: host,
        port: port,
        userName: userName,
        password: password,
        databaseName: databaseName,
      );

      await conn.connect();
      if (kDebugMode) {
        print('Connected to the database successfully.');
      }
      return conn;
    } catch (e) {
      print('Error connecting to the database: $e');
      rethrow;
    }
  }

  // Método para verificar el usuario desde la base de datos
  Future<String?> getPasswordForUser(String username) async {
    final conn = await _getConnection();
    var result = await conn.execute(
      'SELECT password FROM users WHERE username = :username',
      {'username': username},
    );

    await conn.close();

    if (result.rows.isEmpty) {
      return null; // Si no se encuentra el usuario
    }

    // Retornar la contraseña del usuario encontrado
    return result.rows.first.colAt(0);
  }

  /// Obtiene el cliente atendido más reciente
  Future<Customer?> getCurrentCustomers() async {
    final conn = await _getConnection();

    try {
      var result = await conn.execute('''
      SELECT * FROM customers WHERE attended = 1 ORDER BY id DESC LIMIT 1;
    ''');

      if (result.rows.isNotEmpty) {
        Map<String, String?> rowMap = result.rows.first.assoc();
        return Customer(
          id: int.parse(rowMap['id'] ?? '0'),
          fullName: rowMap['full_name'] ?? '',
          vehicleType: rowMap['vehicle_type'] ?? '',
          licensePlate: rowMap['license_plate'] ?? '',
          document: rowMap['document'] ?? '',
          company: rowMap['company'] ?? '',
          ticketNumber: rowMap['ticket_number'] ?? '',
          attended: int.parse(rowMap['attended'] ?? '0'),
        );
      } else {
        return null; // No hay cliente actual
      }
    } catch (e) {
      print('Error al obtener el cliente actual: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  /// Obtiene el próximo cliente no atendido
  Future<Customer?> getNextCustomers() async {
    final conn = await _getConnection();

    try {
      // Consulta para obtener el próximo cliente no atendido
      var result = await conn.execute('''
      SELECT * FROM customers WHERE attended = 0 ORDER BY id ASC LIMIT 1;
    ''');

      if (result.rows.isNotEmpty) {
        Map<String, String?> rowMap = result.rows.first.assoc();
        return Customer(
          id: int.parse(rowMap['id'] ?? '0'),
          fullName: rowMap['full_name'] ?? '',
          vehicleType: rowMap['vehicle_type'] ?? '',
          licensePlate: rowMap['license_plate'] ?? '',
          document: rowMap['document'] ?? '',
          company: rowMap['company'] ?? '',
          ticketNumber: rowMap['ticket_number'] ?? '',
          attended: int.parse(rowMap['attended'] ?? '0'),
        );
      } else {
        return null; // No hay próximo cliente
      }
    } catch (e) {
      print('Error al obtener el próximo cliente: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<Customer?> getLastAttended() async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      var result = await conn.execute(
          'SELECT * FROM customers WHERE attended = 1 AND DATE(created_at) = CURDATE() ORDER BY id DESC LIMIT 1;');

      if (result.rows.isNotEmpty) {
        Map<String, String?> rowMap = result.rows.first.assoc();
        return Customer.fromMap(rowMap);
      }

      return null;
    } catch (e) {
      print('Error fetching most recent unattended customer: $e');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<void> updateCustomerAttended(int customerId) async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      await conn.execute('UPDATE customers SET attended = 1 WHERE id = :id', {
        'id': customerId,
      });
    } catch (e) {
      print('Error updating customer: $e');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  /// Fetches a list of all customers from the database.
  ///
  /// The customers are ordered by `id` in descending order.
  /// Returns a [List<Customer>] or throws an error if the query fails.
  Future<List<Customer>> getCustomers() async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();
      var result =
          await conn.execute("SELECT * FROM customers ORDER BY id DESC;");
      if (kDebugMode) {
        print('Query executed successfully.');
      }

      return result.rows.map((row) {
        Map<String, String?> rowMap = row.assoc();

        // Convertir 'created_at' a DateTime si está presente
        DateTime? createdAt = rowMap['created_at'] != null
            ? DateTime.tryParse(rowMap['created_at']!)
            : null;

        String formattedCreatedAt = createdAt != null
            ? '${createdAt.day.toString().padLeft(2, '0')}/'
                '${createdAt.month.toString().padLeft(2, '0')}/'
                '${createdAt.year} '
                '${createdAt.hour.toString().padLeft(2, '0')}:'
                '${createdAt.minute.toString().padLeft(2, '0')}'
            : 'Unknown';

        return Customer(
          id: int.parse(rowMap['id'] ?? '0'),
          fullName: rowMap['full_name'] ?? '',
          vehicleType: rowMap['vehicle_type'] ?? '',
          licensePlate: rowMap['license_plate'] ?? '',
          document: rowMap['document'] ?? '',
          company: rowMap['company'] ?? '',
          ticketNumber: rowMap['ticket_number'] ?? '',
          attended: rowMap['attended'] != null
              ? int.tryParse(rowMap['attended']!)
              : null,
          createdAt: createdAt,
          formattedCreatedAt: formattedCreatedAt,
        );
      }).toList();
    } catch (e, stacktrace) {
      print('Error fetching customers: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
        if (kDebugMode) {
          print('Connection closed.');
        }
      }
    }
  }

  /// Inserts a new customer into the database with an auto-generated ticket number.
  ///
  /// The ticket number is generated based on the last ticket in the database.
  Future<String> insertCustomer(Customer customer) async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      // Fetch the last ticket number
      var result = await conn.execute(
          'SELECT ticket_number AS last_ticket FROM customers ORDER BY created_at DESC LIMIT 1;');

      String lastTicket = result.rows.first.assoc()['last_ticket'] ?? 'A00';

      // Generate the next ticket number
      String newTicketNumber = _generateNextTicket(lastTicket);

      // Insert the new customer with the generated ticket number
      await conn.execute(
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

      if (kDebugMode) {
        print(
            'Customer inserted successfully with ticket number: $newTicketNumber');
      }

      return newTicketNumber;
    } catch (e, stacktrace) {
      print('Error inserting customer: $e');
      print('Stacktrace: $stacktrace');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
        if (kDebugMode) {
          print('Connection closed.');
        }
      }
    }
  }

  /// Actualiza el campo ready_for_sound para el cliente con el ID dado.
  Future<void> updateReadyForSound(
      int customerId, int readyForSoundValue) async {
    MySQLConnection? conn;
    try {
      // Conectar a la base de datos
      conn = await _getConnection();

      // Ejecutar la consulta para actualizar ready_for_sound con el valor proporcionado
      await conn.execute(
        'UPDATE customers SET ready_for_sound = :ready_for_sound WHERE id = :id',
        {
          'id': customerId,
          'ready_for_sound': readyForSoundValue,
        },
      );

      if (kDebugMode) {
        print(
            'ready_for_sound actualizado a $readyForSoundValue para el cliente con ID: $customerId');
      }
    } catch (e) {
      print('Error al actualizar ready_for_sound: $e');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  /// Generates the next ticket number based on the last ticket.
  ///
  /// Takes the current `lastTicket` as input and returns the next formatted ticket.
  String _generateNextTicket(String lastTicket) {
    // Extract the letter and the number from the last ticket
    String lastLetter = lastTicket[0];
    int lastNumber = int.parse(lastTicket.substring(1));

    // Increment the number
    lastNumber++;

    // If the number exceeds 99, reset to 01 and increment the letter
    if (lastNumber > 99) {
      lastNumber = 1;
      // Increment the letter (A -> B -> C ...)
      lastLetter = String.fromCharCode(lastLetter.codeUnitAt(0) + 1);
    }

    // If the letter exceeds 'Z', reset to 'A'
    if (lastLetter.codeUnitAt(0) > 'Z'.codeUnitAt(0)) {
      lastLetter = 'A';
    }

    // Convert the number to a 2-digit string (e.g., "01", "09", "11", etc.)
    String paddedNumber = lastNumber.toString().padLeft(2, '0');

    // Return the new ticket number (e.g., "A01", "B45", etc.)
    return '$lastLetter$paddedNumber';
  }
}
