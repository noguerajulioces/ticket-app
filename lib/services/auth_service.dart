import 'package:crypto/crypto.dart'; // Para el hashing de la contraseña
import 'dart:convert'; // Para convertir la contraseña a hash
import '../services/database_service.dart'; // Tu DatabaseService

class AuthService {
  final DatabaseService _databaseService = DatabaseService();

  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    // Si el username es 'admin', hacer la autenticación localmente
    if (username == 'admin' && password == '12345') {
      return true;
    }

    // Si el usuario no es 'admin', verificar en la base de datos MySQL
    final dbPassword = await _databaseService.getPasswordForUser(username);

    // Si no se encuentra el usuario, retornar false
    if (dbPassword == null) {
      return false;
    }

    // Hash la contraseña ingresada para compararla con la de la base de datos
    var hashedPassword = sha256.convert(utf8.encode(password)).toString();

    // Verificar si las contraseñas coinciden
    if (dbPassword == hashedPassword) {
      return true;
    }

    return false;
  }
}
