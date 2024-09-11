class AuthService {
  Future<bool> login(String username, String password) async {
    await Future.delayed(
      const Duration(seconds: 2),
    );
    if (username == 'admin' && password == '12345') {
      return true;
    }
    return false;
  }
}
