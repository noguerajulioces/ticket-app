import 'dart:async'; // Importamos para usar Timer
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ticket/services/database_service.dart';
import 'package:ticket/models/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  late FlutterTts flutterTts;
  Customer? _currentCustomer;
  bool _isLoading = true;
  VideoPlayerController? _videoController;
  String? _videoUrl;
  Timer? _pollingTimer; // Declaramos el Timer

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("es-US");
    flutterTts.setPitch(1.0); // Tono normal
    flutterTts.setSpeechRate(0.5); // Velocidad más baja

    // Load the most recent unattended customer and video URL when the screen is initialized
    _loadMostRecentUnattendedCustomer();
    _loadVideoUrl();

    // Iniciar el polling cada 1 segundo
    _pollingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _loadMostRecentUnattendedCustomer();
    });
  }

  // Load the most recent unattended customer
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

  // Load the video URL from SharedPreferences
  Future<void> _loadVideoUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? videoUrl = prefs.getString('videoUrl');

    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {
            _videoController!.play(); // Autoplay the video
          });
        });
    } else {
      setState(() {
        _videoUrl = null;
      });
    }
  }

  // Play the ticket number using text-to-speech
  Future<void> _speakTicketNumber() async {
    if (_currentCustomer != null) {
      String ticketNumber = _currentCustomer!.ticketNumber ?? "No ticket";
      await flutterTts.speak("Ticket $ticketNumber");
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Cancelar el Timer cuando se destruye el widget
    flutterTts.stop();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double ticketFontSize = screenWidth * 0.1;

    return Scaffold(
      body: Row(
        children: [
          // Left section with ticket information
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
                              _currentCustomer?.ticketNumber ?? 'N/A',
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
          // Right section for displaying the video
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              child: Center(
                child: _videoController != null &&
                        _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : const Text(
                        'No video available',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
