import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/login_service.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';
import 'package:data_models/utente_generico.dart';

class LoginController {
  // Dipendenza: il Controller delega la logica di business a LoginService
  final LoginService _loginService = LoginService();

  // Headers standard per le risposte JSON
  final Map<String, String> _headers = {'content-type': 'application/json'};

  // 1. Login classico (Email/Telefono + Password)
  Future<Response> handleLoginRequest(Request request) async {
    try {
      // Lettura e validazione body
      final String body = await request.readAsString();
      if (body.isEmpty) {
        return _buildErrorResponse(400, 'Body della richiesta vuoto');
      }

      final Map<String, dynamic> credentials = jsonDecode(body);

      final email = (credentials['email'] as String?)?.toLowerCase();
      final telefono = credentials['telefono'] as String?;
      final password = credentials['password'] as String?;

      if ((email == null && telefono == null) || password == null) {
        return _buildErrorResponse(
          400,
          'Email/Telefono e Password sono obbligatori.',
        );
      }

      // Chiamata al LoginService per la logica di autenticazione
      final result = await _loginService.login(
        email: email,
        telefono: telefono,
        password: password,
      );

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        return _buildErrorResponse(
          401,
          'Credenziali non valide (combinazione errata o utente non trovato)',
        );
      }
    } on FormatException {
      return _buildErrorResponse(400, 'JSON non valido');
    } catch (e) {
      return _buildErrorResponse(500, 'Errore interno del server: $e');
    }
  }

  // 2. Login con Google
  Future<Response> handleGoogleLoginRequest(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _buildErrorResponse(400, 'Body vuoto');

      final Map<String, dynamic> payload = jsonDecode(body);
      final googleToken = payload['id_token'] as String?;

      if (googleToken == null || googleToken.isEmpty) {
        return _buildErrorResponse(
          400,
          'Token Google mancante nella richiesta.',
        );
      }

      // Delega al LoginService per la verifica del token e la creazione del JWT
      final result = await _loginService.loginWithGoogle(googleToken);

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        return _buildErrorResponse(401, 'Autenticazione Google fallita.');
      }
    } catch (e) {
      return _buildErrorResponse(500, 'Errore durante il login Google: $e');
    }
  }

  // 3. Login con Apple
  Future<Response> handleAppleLoginRequest(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _buildErrorResponse(400, 'Body vuoto');

      final Map<String, dynamic> payload = jsonDecode(body);

      final identityToken = payload['identityToken'] as String?;
      final email = (payload['email'] as String?)?.toLowerCase();
      final firstName = payload['givenName'] as String?;
      final lastName = payload['familyName'] as String?;

      if (identityToken == null || identityToken.isEmpty) {
        return _buildErrorResponse(
          400,
          'Token Apple (identityToken) mancante.',
        );
      }

      // Delega al LoginService
      final result = await _loginService.loginWithApple(
        identityToken: identityToken,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      if (result != null) {
        return _buildSuccessResponse(result);
      } else {
        return _buildErrorResponse(401, 'Autenticazione Apple fallita.');
      }
    } catch (e) {
      return _buildErrorResponse(500, 'Errore durante il login Apple: $e');
    }
  }

  // Metodi di Utility

  // Costruzione Risposta di Successo (200 OK)
  Response _buildSuccessResponse(Map<String, dynamic> result) {
    // Gestione sicura del casting
    final user = result['user'] as UtenteGenerico;
    final token = result['token'] as String;

    String tipoUtente;
    int assignedId = user.id ?? 0;

    // Determina il tipo di utente per messaggio e log
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
          'Login avvenuto con successo. Tipo: $tipoUtente, ID: $assignedId',
      'user': user.toJson()..remove('passwordHash'), // Rimuove dati sensibili
      'token': token,
    };

    return Response.ok(jsonEncode(responseBody), headers: _headers);
  }

  // Costruzione Risposta di Errore (4**, 5**)
  Response _buildErrorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }
}
