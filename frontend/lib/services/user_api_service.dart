import 'dart:convert';
import 'dart:io'; // Necessario per controllare il sistema operativo (Platform)
import 'package:flutter/foundation.dart'; // Necessario per controllare se è Web (kIsWeb)
import 'package:http/http.dart' as http;
import 'package:data_models/user.dart';

class UserApiService {

  // Sostituisci la variabile 'final String _baseUrl' con questo getter dinamico.
  // Questo codice viene eseguito ogni volta che richiami _baseUrl.
  String get _baseUrl {
    // 1. Controllo se siamo sul WEB
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1/user';
    }
    // 2. Controllo se siamo su ANDROID (Emulatore)
    else if (Platform.isAndroid) {
      // L'emulatore vede il localhost del computer come 10.0.2.2
      return 'http://10.0.2.2:8080/api/v1/user';
    }
    // 3. Fallback per iOS o Desktop
    else {
      return 'http://127.0.0.1:8080/api/v1/user';
    }
  }

  Future<User> fetchUser(int userId) async {
    try {
      // Usa il getter _baseUrl
      final response = await http.get(Uri.parse('$_baseUrl/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        throw Exception('Errore server: ${response.statusCode}');
      }
    } catch (e) {
      // È utile catturare l'errore per vedere se è un problema di connessione (SocketException)
      throw Exception('Errore di connessione: $e');
    }
  }
}