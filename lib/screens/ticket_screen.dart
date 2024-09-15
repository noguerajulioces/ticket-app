import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ticket/services/database_service.dart';
import 'package:ticket/models/customer.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late FlutterTts flutterTts;
  Customer? _currentCustomer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("es-MX");
    flutterTts.setPitch(0.7);
    flutterTts.setSpeechRate(1);

    // Load the most recent unattended customer when the screen is initialized
    _loadMostRecentUnattendedCustomer();
  }

  // Method to load the most recent unattended customer
  Future<void> _loadMostRecentUnattendedCustomer() async {
    try {
      DatabaseService dbService = DatabaseService();
      Customer? recentCustomer =
          await dbService.getMostRecentUnattendedCustomer();

      setState(() {
        _currentCustomer = recentCustomer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading customer: $e");
    }
  }

  // Method to play the ticket number
  Future<void> _speakTicketNumber() async {
    if (_currentCustomer != null) {
      String ticketNumber = _currentCustomer!.ticketNumber ?? "No ticket";
      await flutterTts.speak("Ticket $ticketNumber");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double ticketFontSize = screenWidth * 0.1;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.green,
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator() // Show loader while fetching customer
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Ticket',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _speakTicketNumber,
                            child: Text(
                              _currentCustomer?.ticketNumber ??
                                  'N/A', // Display ticket number or 'N/A'
                              style: TextStyle(
                                fontSize: ticketFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              child: const Center(
                child:
                    CircularProgressIndicator(), // Placeholder for additional content
              ),
            ),
          ),
        ],
      ),
    );
  }
}
