// home_screen.dart
import 'package:flutter/material.dart';
import 'package:ticket/screens/layout.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Layout(
      child: Center(
        child: Text(
          '¡Bienvenido a la aplicación de Turnos!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
