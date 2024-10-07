// my_layout.dart
import 'package:flutter/material.dart';

class Layout extends StatelessWidget {
  final Widget child;

  const Layout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantén el AppBar si lo deseas
      appBar: AppBar(
        title: const Text('Generación de Turnos'),
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          // Barra lateral (Columna con flex: 2)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors
                  .grey[200], // Color de fondo para distinguir la barra lateral
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Lista de registrados'),
                    leading: const Icon(Icons.list),
                    onTap: () {
                      Navigator.pushNamed(context, '/customer_list');
                    },
                  ),
                  ListTile(
                    title: const Text('Registrar'),
                    leading: const Icon(Icons.app_registration_rounded),
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                  ListTile(
                    title: const Text('Turnos'),
                    leading: const Icon(Icons.confirmation_number),
                    onTap: () {
                      Navigator.pushNamed(context, '/tickets');
                    },
                  ),
                  ListTile(
                    title: const Text('Configuración'),
                    leading: const Icon(Icons.settings),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  // Añade más opciones si es necesario
                  const Spacer(),
                  // Sección inferior con "Bienvenido"
                  const Column(
                    children: [
                      Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Yerbatera Selent',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              color: Colors.white,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
