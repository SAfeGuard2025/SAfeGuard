import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:data_models/user.dart';

class UserApiService {
  // 1. Definiamo le costanti prendendole dall'ambiente di compilazione
  // Se non vengono passate (es. avvio normale), usano il defaultValue.
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

  String get _baseUrl {
    String host = _envHost;

    // 2. Logica specifica per Android Emulatore
    // Se l'host è localhost (perché è il default o è stato passato così),
    // su Android Emulatore deve diventare 10.0.2.2
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      host = host.replaceFirst('localhost', '10.0.2.2');
    }

    // 3. Costruisci l'URL finale
    return '$host:$_envPort$_envPrefix/user';
  }

  Future<User> fetchUser(int userId) async {
    try {
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
