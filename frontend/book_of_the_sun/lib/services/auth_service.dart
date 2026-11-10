import 'dart:convert';
import '../core/api_client.dart';

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  Future<String?> login(String email, String password) async {
    final response = await api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']?.toString();
      if (token != null) {
        api.setToken(token);
      }
      return token;
    }

    return null;
  }

  Future<bool> register(String email, String password) async {
    final response = await api.post('/auth/register', {
      'email': email,
      'password': password,
    });

    return response.statusCode == 200;
  }
}
