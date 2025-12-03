import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Responsabile di tutte le chiamate API relative ad autenticazione, registrazione e verifica.
class AuthRepository {
  // Costanti dall'ambiente di compilazione
  static const String _envHost = String.fromEnvironment(
    'SERVER_HOST',
    defaultValue: 'http://localhost',
  );
  static const String _envPort = String.fromEnvironment(
    'SERVER_PORT',
    defaultValue: '8080',
  );
  static const String _envPrefix = String.fromEnvironment(
    'API_PREFIX',
    defaultValue: '',
  );

  // Metodo per determinare l'URL base del Backend in base alla piattaforma
  String get _baseUrl {
    String host = _envHost;

    // Logica specifica per emulatore Android (Sovrascrive 'localhost')
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      host = host.replaceFirst('localhost', '10.0.2.2');
    }

    // Aggiunge la porta solo se non è stata disabilitata con "-1"
    final String portPart = _envPort == '-1' ? '' : ':$_envPort';

    // Costruisce l'URL finale (es: http://10.0.2.2:8080 o http://localhost:8080)
    return '$host$portPart$_envPrefix';
  }

  // Login tramite email o telefono
  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');

    // Costruisce il body dinamicamente in base ai dati forniti
    final Map<String, dynamic> body = {'password': password};
    if (email != null) body['email'] = email;
    if (phone != null) body['telefono'] = phone;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseBody;
      } else if (response.statusCode == 403 &&
          responseBody['error'] == 'USER_NOT_VERIFIED') {
        // Ritorniamo la mappa con l'errore specifico invece di lanciare un'eccezione generica
        return responseBody;
      } else {
        throw Exception(responseBody['message'] ?? "Errore durante il login");
      }
    } catch (e) {
      throw Exception("Errore di connessione: $e");
    }
  }

  // Registrazione con email o telefono
  Future<void> register(
      String identifier,
      String password,
      String nome,
      String cognome,
      ) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');

    // Tenta di determinare se l'identificatore è un numero di telefono (inizia con + o cifre)
    final bool isPhone = RegExp(r'^[+0-9]').hasMatch(identifier);

    final Map<String, dynamic> bodyMap = {
      'password': password,
      'confermaPassword': password,
      'nome': nome,
      'cognome': cognome,
    };

    if (isPhone) {
      bodyMap['telefono'] = identifier;
    } else {
      bodyMap['email'] = identifier;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Errore registrazione");
      }
    } catch (e) {
      throw Exception("Errore di connessione: $e");
    }
  }

  // Invio OTP Telefono
  Future<void> sendPhoneOtp(
      String phoneNumber, {
        String? password,
        String? nome,
        String? cognome,
      }) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');
    try {
      final Map<String, dynamic> body = {
        'telefono': phoneNumber,
        'nome': nome,
        'cognome': cognome,
      };

      if (password != null) {
        body['password'] = password;
        body['confermaPassword'] = password;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Errore invio SMS");
      }
    } catch (e) {
      throw Exception("Errore connessione: $e");
    }
  }

  // Verifica OTP
  // Verifica per email o telefono. Restituisce token se login completato.
  Future<Map<String, dynamic>> verifyOtp({
    String? email,
    String? phone,
    required String code,
  }) async {
    final url = Uri.parse('$_baseUrl/api/verify');
    final Map<String, dynamic> requestBody = {'code': code};
    if (email != null) requestBody['email'] = email;
    if (phone != null) requestBody['telefono'] = phone;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        throw Exception(body['message'] ?? "Codice non valido");
      }
    } catch (e) {
      throw Exception("Errore verifica: $e");
    }
  }

  // Login Google
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final url = Uri.parse('$_baseUrl/api/auth/google');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        throw Exception(body['message'] ?? "Errore login Google");
      }
    } catch (e) {
      throw Exception("Errore connessione: $e");
    }
  }

  // Login Apple
  Future<Map<String, dynamic>> loginWithApple({
    required String identityToken,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/apple');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identityToken': identityToken,
          'email': email,
          'givenName': firstName,
          'familyName': lastName,
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body;
      } else {
        throw Exception(body['message'] ?? "Errore login Apple");
      }
    } catch (e) {
      throw Exception("Errore connessione: $e");
    }
  }

  //Aggiorna token FCM
  Future<void> updateFCMToken(String tokenFCM, String authToken) async {
    final url = Uri.parse('$_baseUrl/api/profile/device/token');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'tokenFCM': tokenFCM}),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        debugPrint('FCM TOKEN UPDATE FALLITO: ${response.body}');
      } else {
        debugPrint('FCM TOKEN salvato con successo.');
      }
    } catch (e) {
      debugPrint("Errore connessione FCM: $e");
    }
  }
}
  // Metodo per rinviare
  Future<void> resendOtp({String? email, String? phone}) async {
    final url = Uri.parse('$_baseUrl/api/auth/resend');

    final Map<String, dynamic> body = {};
    if (email != null) body['email'] = email;
    if (phone != null) body['telefono'] = phone;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Errore rinvio codice");
      }
    } catch (e) {
      throw Exception("Errore connessione: $e");
    }
  }
}
