import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los TextFormField
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _userNameController;
  late TextEditingController _passwordController;
  late TextEditingController _databaseNameController;
  File? _videoUrl; // Cambiamos a File

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores
    _hostController = TextEditingController();
    _portController = TextEditingController();
    _userNameController = TextEditingController();
    _passwordController = TextEditingController();
    _databaseNameController = TextEditingController();

    _loadSettings(); // Cargar la configuración cuando se inicialice la pantalla
  }

  // Método para cargar la configuración desde SharedPreferences
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _hostController.text = prefs.getString('dbHost') ?? '';
      _portController.text = prefs.getString('dbPort') ?? '';
      _userNameController.text = prefs.getString('dbUserName') ?? '';
      _passwordController.text = prefs.getString('dbPassword') ?? '';
      _databaseNameController.text = prefs.getString('dbName') ?? '';

      // Convertir la ruta guardada en un File
      String? videoPath = prefs.getString('videoUrl');
      if (videoPath != null && videoPath.isNotEmpty) {
        _videoUrl = File(videoPath);
      }
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Guardar configuración de la base de datos desde los controladores
      await prefs.setString('dbHost', _hostController.text);
      await prefs.setString('dbPort', _portController.text);
      await prefs.setString('dbUserName', _userNameController.text);
      await prefs.setString('dbPassword', _passwordController.text);
      await prefs.setString('dbName', _databaseNameController.text);

      // Guardar la ruta del video
      if (_videoUrl != null) {
        await prefs.setString('videoUrl', _videoUrl!.path);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Configuración guardada!')),
      );
    }
  }

  Future<void> _selectVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      // Convertir la ruta del archivo a un File
      setState(() {
        _videoUrl = File(result.files.single.path!);
      });

      // Guardar la ruta del archivo en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('videoUrl', _videoUrl!.path);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Video guardado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(right: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _hostController,
                        decoration: const InputDecoration(labelText: 'Host'),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _portController,
                        decoration: const InputDecoration(labelText: 'Port'),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _userNameController,
                        decoration:
                            const InputDecoration(labelText: 'User Name'),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _databaseNameController,
                        decoration:
                            const InputDecoration(labelText: 'Database Name'),
                      ),
                      const SizedBox(height: 30),

                      // Botón para seleccionar el video
                      ElevatedButton(
                        onPressed: _selectVideo,
                        child: const Text('Seleccionar Video'),
                      ),
                      const SizedBox(height: 30),

                      // Botón para guardar configuraciones
                      ElevatedButton(
                        onPressed: _saveSettings,
                        child: const Text('Guardar configuración'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(left: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuración Actual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Host: ${_hostController.text}'),
                    const SizedBox(height: 10),
                    Text('Port: ${_portController.text}'),
                    const SizedBox(height: 10),
                    Text('User Name: ${_userNameController.text}'),
                    const SizedBox(height: 10),
                    Text('Database Name: ${_databaseNameController.text}'),
                    const SizedBox(height: 20),
                    if (_videoUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('Selected video: ${_videoUrl!.path}'),
                      ),
                    if (_videoUrl == null) const Text('No video selected'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _databaseNameController.dispose();
    super.dispose();
  }
}
