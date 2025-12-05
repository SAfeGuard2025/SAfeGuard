import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyRepository {
  // --- CONFIGURAZIONE AMBIENTE (Identica ad AuthRepository) ---

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
    // Fix per emulatore Android
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      host = host.replaceFirst('localhost', '10.0.2.2');
    }
    final String portPart = _envPort == '-1' ? '' : ':$_envPort';
    return '$host$portPart$_envPrefix';
  }

  // Helper per ottenere il Token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- METODI API ---

  /// Invia SOS al Backend (POST /api/emergency)
  Future<void> sendSos({
    required String type,
    required double lat,
    required double lng,
    String? phone,
    String? email,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/emergenza');

    if (token == null) {
      throw Exception("Utente non autenticato (Token mancante)");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Fondamentale per il Backend
        },
        body: jsonEncode({
          'type': type,
          'lat': lat,
          'lng': lng,
          'phone': phone,
          'email': email,
        }),
      );

      // Gestione Errori
      if (response.statusCode != 200 && response.statusCode != 201) {
        // Proviamo a leggere il messaggio di errore dal backend se c'è
        String errorMsg = "Errore invio SOS";
        try {
          final body = jsonDecode(response.body);
          errorMsg = body['message'] ?? body['error'] ?? errorMsg;
        } catch (_) {}

        throw Exception("$errorMsg (Codice: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Errore di connessione SOS: $e");
    }
  }

  /// Annulla SOS (DELETE /api/emergency)
  Future<void> stopSos() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/emergency');

    if (token == null) return;

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Impossibile annullare SOS (Codice: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Errore connessione Stop SOS: $e");
    }
  }
}