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

  Future<List<Customer>> getCurrentAndNextCustomers() async {
    final conn = await _getConnection();

    try {
      // Ejecutar la consulta combinada
      var result = await conn.execute('''
        (
          SELECT * FROM customers WHERE attended = 1 ORDER BY id DESC LIMIT 1
        ) 
        UNION ALL 
        (
          SELECT * FROM customers WHERE attended = 0 ORDER BY id ASC LIMIT 1
        );
      ''');

      List<Customer> customers = result.rows.map((row) {
        // Convierte la fila en un Customer
        Map<String, String?> rowMap = row.assoc();
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
      }).toList();

      return customers; // Retorna los clientes en una lista
    } catch (e) {
      print('Error al obtener los clientes: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<Customer?> getMostRecentUnattendedCustomer() async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      // Query to get the most recent customer where attended is false, ordered by id in descending order
      var result = await conn.execute(
          'SELECT * FROM customers WHERE attended = 0 ORDER BY id ASC LIMIT 1;');

      if (result.rows.isNotEmpty) {
        Map<String, String?> rowMap = result.rows.first.assoc();
        return Customer.fromMap(
            rowMap); // Convert the first row to a Customer object
      }

      return null; // No more customers where attended is false
    } catch (e) {
      print('Error fetching most recent unattended customer: $e');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
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

  Future<Customer?> getNextCustomer() async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      // Assuming you order customers by 'id' or 'ticket_number'
      var result = await conn.execute(
          'SELECT * FROM customers WHERE attended = 0 ORDER BY id ASC LIMIT 1;');

      if (result.rows.isNotEmpty) {
        Map<String, String?> rowMap = result.rows.first.assoc();
        return Customer.fromMap(
            rowMap); // Convert the first row to a Customer object
      }

      return null; // No more customers
    } catch (e) {
      print('Error fetching next customer: $e');
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
  Future<void> insertCustomer(Customer customer) async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      // Fetch the last ticket number
      var result = await conn
          .execute('SELECT MAX(ticket_number) AS last_ticket FROM customers');
      String lastTicket = result.rows.first.assoc()['last_ticket'] ?? 'A0';

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

  /// Generates the next ticket number based on the last ticket.
  ///
  /// Takes the current `lastTicket` as input and returns the next formatted ticket.
  String _generateNextTicket(String lastTicket) {
    // Extract the letter and the number from the last ticket
    String lastLetter = lastTicket[0];
    int lastNumber = int.parse(lastTicket.substring(1));

    // Increment the number
    lastNumber++;

    // If the number exceeds 99, reset to 1 and increment the letter
    if (lastNumber > 99) {
      lastNumber = 1;
      // Increment the letter (A -> B -> C ...)
      lastLetter = String.fromCharCode(lastLetter.codeUnitAt(0) + 1);
    }

    // If the letter exceeds 'Z', reset to 'A'
    if (lastLetter.codeUnitAt(0) > 'Z'.codeUnitAt(0)) {
      lastLetter = 'A';
    }

    // Return the new ticket number (e.g., "A1", "B45", etc.)
    return '$lastLetter$lastNumber';
  }
}
