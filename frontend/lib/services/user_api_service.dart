import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importa il pacchetto
import 'package:data_models/user.dart';

class UserApiService {
  // Getter dinamico che combina .env e logica platform-specific
  String get _baseUrl {
    // 1. Leggi i valori dal .env (con valori di fallback per sicurezza)
    String host = dotenv.env['SERVER_HOST'] ?? 'http://localhost';
    String port = dotenv.env['SERVER_PORT'] ?? '8080';
    String prefix = dotenv.env['API_PREFIX'] ?? '';

    // 2. Logica specifica per Android Emulatore
    // Se l'host configurato è localhost, ma siamo su Android, dobbiamo "patcharlo"
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      host = host.replaceFirst('localhost', '10.0.2.2');
    }

    // 3. Costruisci l'URL finale
    return '$host:$port$prefix/user';
  }

  Future<User> fetchUser(int userId) async {
    try {
      // La chiamata è identica a prima, ma _baseUrl ora è configurabile
      final response = await http.get(Uri.parse('$_baseUrl/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        throw Exception('Errore server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore di connessione: $e');
    }
  }
}
