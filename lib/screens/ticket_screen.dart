import 'dart:async'; // Importamos para usar Timer
import 'dart:io';
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
    flutterTts.setSpeechRate(0.3); // Velocidad más baja

    // Load the most recent unattended customer and video URL when the screen is initialized
    _loadMostRecentUnattendedCustomer();
    _loadVideoUrl();

    // Iniciar el polling cada 1 segundo
    _pollingTimer = Timer.periodic(
        const Duration(
          seconds: 1,
        ), (timer) {
      _loadMostRecentUnattendedCustomer();
    });
  }

  // Load the most recent unattended customer
  Future<void> _loadMostRecentUnattendedCustomer() async {
    try {
      DatabaseService dbService = DatabaseService();
      Customer? recentCustomer = await dbService.getLastAttended();

      // Verificamos si ready_for_sound es 1
      if (recentCustomer?.readyForSound == 1) {
        // Llamamos al método TTS para hablar el número de ticket
        await _speakTicketNumber();

        // Actualizamos ready_for_sound a 0 en la base de datos para que no vuelva a sonar
        await dbService.updateReadyForSound(recentCustomer!.id!, 0);
      }

      // Verificamos si el cliente ha cambiado
      if (_currentCustomer == null ||
          _currentCustomer!.id != recentCustomer!.id) {
        setState(() {
          _currentCustomer = recentCustomer;
          _isLoading = false;
        });

        // Llamamos al método TTS solo si hay un nuevo cliente
        await _speakTicketNumber();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print("Error loading customer: $e");
    }
  }

  // Load the video URL from SharedPreferences
  // Método para cargar la URL del video guardada en SharedPreferences
  Future<void> _loadVideoUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? videoUrl = prefs.getString('videoUrl');

    if (videoUrl != null && videoUrl.isNotEmpty) {
      setState(() {
        _videoUrl = videoUrl;
      });

      // Inicializar el controlador del video
      _videoController = VideoPlayerController.file(File(_videoUrl!))
        ..initialize().then((_) {
          setState(() {
            _isLoading = false;
            _videoController!.setVolume(0.0);
            _videoController!.setLooping(true);
            _videoController!.play();
          });
        });
    } else {
      setState(() {
        _isLoading = false;
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
    double ticketFontSize = screenWidth * 0.08;

    return Scaffold(
      body: Stack(
        children: [
          Row(
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
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : _videoUrl != null &&
                                _videoController != null &&
                                _videoController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                            : const Text('No video available'),
                  ),
                ),
              ),
            ],
          ),
          // Botón pequeño para volver al inicio
          Positioned(
            top: 20, // Puedes ajustar la posición vertical
            left: 20, // Puedes ajustar la posición horizontal
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              iconSize: 20, // Tamaño del ícono
              onPressed: () {
                Navigator.of(context).pop(); // Volver a la pantalla anterior
              },
            ),
          ),
        ],
      ),
    );
  }
}
