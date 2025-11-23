import 'dart:convert';
import '../services/LoginService.dart';
import '../repositories/UserRepository.dart';

class LoginController {
  final LoginService _loginService = LoginService();

  Future<String> handleLoginRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> credentials = jsonDecode(requestBodyJson);

      // Estrae email e telefono (possono essere null)
      final email = credentials['email'] as String?;
      final telefono = credentials['telefono'] as String?;
      final password = credentials['password'] as String;

      // Chiama il service con i parametri opzionali
      final user = await _loginService.login(
          email: email,
          telefono: telefono,
          password: password
      );

      if (user != null) {
        final responseBody = {
          'success': true,
          'message': 'Login avvenuto con successo',
          'user': user.toJson()..remove('passwordHash'),
        };
        return jsonEncode(responseBody);
      } else {
        final responseBody = {
          'success': false,
          'message': 'Credenziali non valide (combinazione errata o utente non trovato)',
        };
        return jsonEncode(responseBody);
      }
    } on ArgumentError catch (e) {
      final responseBody = {
        'success': false,
        'message': e.message, // Cattura l'errore se mancano email E telefono
      };
      return jsonEncode(responseBody);
    } catch (e) {
      final responseBody = {
        'success': false,
        'message': 'Errore interno del server: $e',
      };
      return jsonEncode(responseBody);
    }
  }
}