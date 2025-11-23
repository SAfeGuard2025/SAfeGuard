import 'dart:convert';

import '../services/LoginService.dart';

class AuthController {
  final LoginService _loginService = LoginService();

  // Simula la gestione di una richiesta HTTP POST /api/login
  Future<String> handleLoginRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> credentials = jsonDecode(requestBodyJson);
      final email = credentials['email'] as String;
      final password = credentials['password'] as String;

      final user = await _loginService.login(email, password);

      if (user != null) {
        // SUCCESS: Serializza l'oggetto Utente/Soccorritore in JSON (senza hash)
        final responseBody = {
          'success': true,
          'message': 'Login avvenuto con successo',
          'user': user.toJson(),
        };
        return jsonEncode(responseBody);
      } else {
        // FAIL: Credenziali non valide
        final responseBody = {
          'success': false,
          'message': 'Credenziali non valide (email o password errata)',
        };
        return jsonEncode(responseBody);
      }
    } catch (e) {
      // Errore generico (es. JSON malformato)
      final responseBody = {
        'success': false,
        'message': 'Errore interno del server: $e',
      };
      return jsonEncode(responseBody);
    }
  }
}