import 'dart:convert';
import '../services/LoginService.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';

class LoginController {
  final LoginService _loginService = LoginService();

  // 1. Login classico (Email/Telefono + Password)
  Future<String> handleLoginRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> credentials = jsonDecode(requestBodyJson);

      final email = credentials['email'] as String?;
      final telefono = credentials['telefono'] as String?;
      final password = credentials['password'] as String;

      final result = await _loginService.login(
        email: email,
        telefono: telefono,
        password: password,
      );

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        return _buildErrorResponse(
          'Credenziali non valide (combinazione errata o utente non trovato)',
        );
      }
    } on ArgumentError catch (e) {
      return _buildErrorResponse(e.message);
    } catch (e) {
      return _buildErrorResponse('Errore interno del server: $e');
    }
  }

  // 2. Login con Google
  Future<String> handleGoogleLoginRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> payload = jsonDecode(requestBodyJson);

      // Il frontend deve inviare una chiave 'id_token'
      final googleToken = payload['id_token'] as String?;

      if (googleToken == null || googleToken.isEmpty) {
        return _buildErrorResponse('Token Google mancante nella richiesta.');
      }

      // Chiama il service che gestisce la logica "Find or Create"
      final result = await _loginService.loginWithGoogle(googleToken);

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        // Teoricamente loginWithGoogle lancia eccezioni se fallisce, ma gestiamo il null per sicurezza
        return _buildErrorResponse('Autenticazione Google fallita.');
      }
    } catch (e) {
      // Cattura le eccezioni lanciate dal Service (es. "Token Google non valido")
      return _buildErrorResponse('Errore durante il login Google: $e');
    }
  }

  Future<String> handleAppleLoginRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> payload = jsonDecode(requestBodyJson);

      // Parametri inviati dal frontend (Flutter "sign_in_with_apple")
      final identityToken = payload['identityToken'] as String?;
      final email = payload['email'] as String?;
      final firstName =
          payload['givenName'] as String?; // Apple chiama così il nome
      final lastName = payload['familyName'] as String?; // e così il cognome

      if (identityToken == null || identityToken.isEmpty) {
        return _buildErrorResponse('Token Apple (identityToken) mancante.');
      }

      final result = await _loginService.loginWithApple(
        identityToken: identityToken,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        return _buildErrorResponse('Autenticazione Apple fallita.');
      }
    } catch (e) {
      return _buildErrorResponse('Errore durante il login Apple: $e');
    }
  }

  // Costruzione Risposta di Successo
  // Centralizza la logica di formattazione della risposta per evitare duplicati
  String _buildSuccessResponse(Map<String, dynamic> result) {
    final user = result['user'] as UtenteGenerico;
    final token = result['token'] as String;

    String tipoUtente;
    int assegnatoId = user.id ?? 0;

    if (user is Soccorritore) {
      tipoUtente = 'Soccorritore';
    } else if (user is Utente) {
      tipoUtente = 'Utente Standard';
    } else {
      tipoUtente = 'Generico';
    }

    final responseBody = {
      'success': true,
      'message':
          'Login avvenuto con successo. Tipo: $tipoUtente, ID: $assegnatoId',
      'user': user.toJson()..remove('passwordHash'), // Rimuove dati sensibili
      'token': token,
    };

    return jsonEncode(responseBody);
  }

  //Costruzione Risposta di Errore
  String _buildErrorResponse(String message) {
    return jsonEncode({'success': false, 'message': message});
  }
}
