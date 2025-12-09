import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Repository: ReportRepository
// Gestisce la comunicazione HTTP verso il Backend per le segnalazioni specifiche.
class ReportRepository {
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

  // Crea segnalazione
  Future<void> createReport(String type, String description, double? lat, double? lng, int severity) async {
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
          'severity': severity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Errore server: ${response.body}');
      }
    } catch (e) {
      throw Exception('Errore connessione: $e');
    }
  }

  //Crea report su Firestore direttamente per ottenere subito l'ID e fare tracking
  Future<String> createReportAndGetId(String type, String description, double lat, double lng, int severity) async {
    DocumentReference docRef = FirebaseFirestore.instance.collection('active_emergencies').doc();

    await docRef.set({
      'type': type,
      'description': description,
      'lat': lat,
      'lng': lng,
      'severity': severity,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'active',
    });

    return docRef.id;
  }

  // --- NUOVO: Aggiorna la posizione di un report esistente ---
  Future<void> updateReportLocation(String reportId, double lat, double lng) async {
    await FirebaseFirestore.instance.collection('active_emergencies').doc(reportId).update({
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(), // Aggiorna timestamp per mantenere il pallino vivo
    });
  }

  // Recupera la lista delle segnalazioni
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

  // Chiude una segnalazione
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

  // Recupera la lista delle emergenze attive
  Stream<List<Map<String, dynamic>>> getReportsStream() {
    return FirebaseFirestore.instance
        .collection('active_emergencies')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}