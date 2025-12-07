import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Repository: EmergencyRepository
// Gestisce la comunicazione HTTP verso il Backend per le operazioni di emergenza.
class EmergencyRepository {
  // Recupera host e porta dalle variabili d'ambiente o usa i default.
  static const String _envHost = String.fromEnvironment('SERVER_HOST', defaultValue: 'http://localhost');
  static const String _envPort = String.fromEnvironment('SERVER_PORT', defaultValue: '8080');
  static const String _envPrefix = String.fromEnvironment('API_PREFIX', defaultValue: '');

  // Costruisce l'URL base corretto, gestendo la differenza tra localhost e 10.0.2.2 per Android.
  String get _baseUrl {
    String host = _envHost;
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      host = host.replaceFirst('localhost', '10.0.2.2');
    }
    final String portPart = _envPort == '-1' ? '' : ':$_envPort';
    return '$host$portPart$_envPrefix';
  }

  // Helper per recuperare il Token JWT salvato localmente (necessario per l'autenticazione).
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Invio SOS
  // Invia i dati iniziali dell'emergenza al server per creare il record nel DB.
  Future<void> sendSos({
    required String type,
    required double lat,
    required double lng,
    String? phone,
    String? email,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/emergency');

    if (token == null) throw Exception("Token mancante");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
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
        throw Exception("Errore Server: ${response.body}");
      }
    } catch (e) {
      throw Exception("Errore connessione SOS: $e");
    }
  }

  // Stop SOS
  // Segnala al server di chiudere e cancellare l'emergenza attiva.
  Future<void> stopSos() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/emergency');

    if (token == null) return;

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception("Impossibile annullare SOS: ${response.statusCode}");
    }
  }

  // Aggiornamento posizione
  // Invia aggiornamenti leggeri delle sole coordinate mentre l'utente si muove.
  Future<void> updateLocation(double lat, double lng) async {
    final token = await _getToken();

    if (token == null) return;

    final url = Uri.parse('$_baseUrl/api/emergency/location');

    try {
      await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'lat': lat, 'lng': lng}),
      );
    } catch (e) {
      debugPrint("[REPO] ERRORE DI RETE TRACKING: $e");
    }
  }
}