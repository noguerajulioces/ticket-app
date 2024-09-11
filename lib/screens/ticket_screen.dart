import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();

    flutterTts.setLanguage("es-MX");
    flutterTts.setPitch(0.7);
    flutterTts.setSpeechRate(1);
  }

  // Método para reproducir la voz del ticket
  Future<void> _speakTicketNumber() async {
    await flutterTts.speak("Ticket J6");
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
                child: Column(
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
                        '#J6',
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
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
