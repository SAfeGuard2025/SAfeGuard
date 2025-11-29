import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:data_models/UtenteGenerico.dart';

// Servizio API: UserApiService
// Classe responsabile per l'interazione con l'endpoint degli utenti del Backend
class UserApiService {
  // 1. Definizione delle costanti prese dall'ambiente di compilazione
  // Se le costanti non sono definite, vengono usati i valori di default.
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

  // Getter per costruire l'URL base dinamicamente
  String get _baseUrl {
    String host = _envHost;

    // 2. Logica specifica per emulatore Android (Sovrascrive 'localhost').
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      // Sostituisce 'localhost' con l'IP speciale per l'emulatore
      host = host.replaceFirst('localhost', '10.0.2.2');
    }

    // Aggiunge la porta solo se non è stata disabilitata con "-1"
    final String portPart = _envPort == '-1' ? '' : ':$_envPort';

    // 3. Costruisce l'URL finale
    return '$host$portPart$_envPrefix/user';
  }

  // Recupera i dati di un utente tramite ID
  Future<UtenteGenerico> fetchUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        return UtenteGenerico.fromJson(userData);
      } else {
        throw Exception('Errore server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Errore di connessione: $e');
    }
  }
}
