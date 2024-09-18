import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _videoUrl;

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
      // Asignar los valores de SharedPreferences a los controladores
      _hostController.text = prefs.getString('dbHost') ?? '';
      _portController.text = prefs.getString('dbPort') ?? '';
      _userNameController.text = prefs.getString('dbUserName') ?? '';
      _passwordController.text = prefs.getString('dbPassword') ?? '';
      _databaseNameController.text = prefs.getString('dbName') ?? '';
      _videoUrl = prefs.getString('videoUrl') ?? '';
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
        await prefs.setString('videoUrl', _videoUrl!);
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

    if (result != null) {
      String? filePath = result.files.single.path;
      setState(() {
        _videoUrl = filePath;
      });

      // Guardar la ruta del video en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('videoUrl', _videoUrl!);
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
        padding: const EdgeInsets.all(
            32.0), // Padding más amplio alrededor del contenedor
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Centrar horizontalmente
          children: [
            // Parte izquierda: Formulario
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(
                    right: 16.0), // Espacio entre los Expanded
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Fondo gris claro
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0, // Sombra suave
                      offset: Offset(2, 2), // Desplazamiento de la sombra
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

            // Parte derecha: Mostrar información actual
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(
                    left: 16.0), // Espacio entre los Expanded
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Fondo gris aún más claro
                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0, // Sombra suave
                      offset: Offset(2, 2), // Desplazamiento de la sombra
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
                    if (_videoUrl != null && _videoUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('Selected video: $_videoUrl'),
                      ),
                    if (_videoUrl == null || _videoUrl!.isEmpty)
                      const Text('No video selected'),
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
    // Liberar los controladores
    _hostController.dispose();
    _portController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _databaseNameController.dispose();
    super.dispose();
  }
}
