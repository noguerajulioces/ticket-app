import 'package:flutter/material.dart';

import 'package:ticket/screens/customer_list_screen.dart';
import 'package:ticket/screens/login_screen.dart';
import 'package:ticket/screens/settings_screen.dart';
import 'package:ticket/screens/ticket_screen.dart';

import 'screens/home_screen.dart';
import 'screens/register_customer_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Generación de Turnos',
      theme: ThemeData(
        primaryColor: const Color(0xFF00A2ED),
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF00A2ED),
          ),
        ),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00A2ED),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
              size: 15.0,
            )),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterCustomerScreen(),
        '/customer_list': (context) => CustomerListScreen(),
        '/tickets': (context) => TicketScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
