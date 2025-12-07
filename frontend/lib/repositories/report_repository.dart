import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportRepository {
  // Configurazione URL base (copiata dalla logica degli altri tuoi repository)
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
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      host = host.replaceFirst('localhost', '10.0.2.2');
    }
    final String portPart = _envPort == '-1' ? '' : ':$_envPort';
    return '$host$portPart$_envPrefix';
  }

  // Metodo per recuperare il token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // CREA SEGNALAZIONE (POST)
  Future<void> createReport(String type, String description, double? lat, double? lng) async {
    final token = await _getToken();
    if (token == null) throw Exception("Utente non autenticato");

    final url = Uri.parse('$_baseUrl/api/reports/create');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': type,
          'description': description,
          'lat': lat,
          'lng': lng,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Errore server: ${response.body}');
      }
    } catch (e) {
      throw Exception('Errore connessione: $e');
    }
  }
  Future<List<dynamic>> getReports() async {
    final token = await _getToken();
    if (token == null) throw Exception("Utente non autenticato");

    final url = Uri.parse('$_baseUrl/api/reports/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Errore caricamento report: ${response.body}');
    }
  }

  //Chiude una emergenza
  Future<void> closeReport(String id) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/reports/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Errore chiusura report: ${response.body}');
    }
  }


  Stream<List<Map<String, dynamic>>> getReportsStream() {
    return FirebaseFirestore.instance
        .collection('active_emergencies')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Importante per identificare il report
        return data;
      }).toList();
    });
  }
}