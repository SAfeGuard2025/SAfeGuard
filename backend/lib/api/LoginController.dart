import 'dart:convert';
import '../services/LoginService.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';

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
      // Il service ora ritorna una Map<String, dynamic> contenente 'user' e 'token'
      final result = await _loginService.login(
        email: email,
        telefono: telefono,
        password: password,
      );

      if (result != null) {
        // 1. Estrai l'oggetto utente e il token dal risultato del service
        final user = result['user'] as UtenteGenerico;
        final token = result['token'] as String;

        // 2. Verifica il tipo concreto di utente e ottieni l'ID
        String tipoUtente;
        int assegnatoId =
            user.id ?? 0; // L'ID non è nullo qui, ma usiamo ?? per sicurezza

        if (user is Soccorritore) {
          tipoUtente = 'Soccorritore';
        } else if (user is Utente) {
          tipoUtente = 'Utente Standard';
        } else {
          tipoUtente = 'Generico';
        }

        // 3. Costruisci la risposta con il token e le info utente
        final responseBody = {
          'success': true,
          'message':
              'Login avvenuto con successo. Tipo: $tipoUtente, ID: $assegnatoId',
          'user': user.toJson()
            ..remove('passwordHash'), // Invia i dati utente senza hash
          'token': token, // Invia il Token JWT al client
        };
        return jsonEncode(responseBody);
      } else {
        final responseBody = {
          'success': false,
          'message':
              'Credenziali non valide (combinazione errata o utente non trovato)',
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
