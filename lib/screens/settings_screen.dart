import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _videoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVideoUrl();
  }

  // Método para cargar la URL del video guardada en las preferencias
  Future<void> _loadVideoUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _videoUrl = prefs.getString('videoUrl') ?? '';
    });
  }

  // Método para guardar la URL del video
  Future<void> _saveVideoUrl() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('videoUrl', _videoUrl!);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video URL saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  initialValue: _videoUrl,
                  decoration: const InputDecoration(labelText: 'Video URL'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the video URL';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _videoUrl = value;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _saveVideoUrl,
                        child: const Text('Save Video URL'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
