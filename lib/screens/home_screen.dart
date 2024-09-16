import 'package:flutter/material.dart';
import 'package:ticket/screens/layout.dart';
import 'package:ticket/services/database_service.dart';
import 'package:ticket/models/customer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  Customer? _currentCustomer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNextCustomer(); // Load the first customer on screen load
  }

  /// Loads the next customer from the database and updates the UI.
  Future<void> _loadNextCustomer() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_currentCustomer == null) {
        // If there's no current customer, fetch the last customer whose attended is false
        final recentCustomer =
            await _dbService.getMostRecentUnattendedCustomer();
        setState(() {
          _currentCustomer = recentCustomer;
          _isLoading = false;
        });
      } else {
        // Step 1: Mark the current customer as attended
        await _dbService.updateCustomerAttended(_currentCustomer!.id!);

        // Step 2: Fetch the next customer from the database
        final nextCustomer = await _dbService.getNextCustomer();

        // Step 3: Update the state with the next customer
        setState(() {
          _currentCustomer = nextCustomer;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading next customer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // Show a loading spinner while fetching the customer
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _currentCustomer != null
                      ? Column(
                          children: [
                            Text(
                              'Próximo Cliente: ${_currentCustomer!.fullName}',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Ticket Number: ${_currentCustomer!.ticketNumber ?? 'N/A'}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : const Text('No more customers.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadNextCustomer,
                    child: const Text('Atender Cliente'),
                  ),
                ],
              ),
      ),
    );
  }
}
