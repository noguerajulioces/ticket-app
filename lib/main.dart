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
        primarySwatch: Colors.blue,
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
