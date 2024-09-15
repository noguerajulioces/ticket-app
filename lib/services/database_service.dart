import 'package:flutter/foundation.dart';
import 'package:mysql_client/mysql_client.dart';
import '../models/customer.dart';

/// Service for interacting with the MySQL database, handling customer CRUD operations.
class DatabaseService {
  /// Private method to establish a MySQL connection.
  ///
  /// Returns an open [MySQLConnection] or throws an error if the connection fails.
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
      if (kDebugMode) {
        print('Connected to the database successfully.');
      }
      return conn;
    } catch (e) {
      print('Error connecting to the database: $e');
      rethrow;
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

  Future<void> updateCustomerAttended(int customerId) async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      await conn.execute('UPDATE customers SET attended = 1 WHERE id = :id', {
        'id': customerId,
      });

      print('Customer marked as attended.');
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
      String lastTicket =
          result.rows.first.assoc()['last_ticket'] ?? 'TKT-0000';

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
    int lastTicketNumber = int.parse(lastTicket.split('-')[1]);
    int newTicketNumber = lastTicketNumber + 1;
    return 'TKT-${newTicketNumber.toString().padLeft(4, '0')}';
  }

  /// Updates an existing customer in the database.
  ///
  /// Takes a [Customer] object and updates the corresponding record in the database.
  Future<void> updateCustomer(Customer customer) async {
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
      if (kDebugMode) {
        print('Customer updated successfully.');
      }
    } catch (e, stacktrace) {
      print('Error updating customer: $e');
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

  /// Deletes a customer from the database by their ID.
  ///
  /// Takes the [id] of the customer and deletes the corresponding record.
  Future<void> deleteCustomer(int id) async {
    MySQLConnection? conn;
    try {
      conn = await _getConnection();

      await conn.execute('DELETE FROM customers WHERE id = :id', {'id': id});
      if (kDebugMode) {
        print('Customer deleted successfully.');
      }
    } catch (e, stacktrace) {
      print('Error deleting customer: $e');
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
}
