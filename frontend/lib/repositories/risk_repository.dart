import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_models/risk_hotspot.dart';

class RiskRepository {
  //Configurazione URL
  static const String _envHost = String.fromEnvironment('SERVER_HOST', defaultValue: 'http://localhost');
  static const String _envPort = String.fromEnvironment('SERVER_PORT', defaultValue: '8080');
  static const String _envPrefix = String.fromEnvironment('API_PREFIX', defaultValue: '');

  String get _baseUrl {
    String host = _envHost;
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      host = host.replaceFirst('localhost', '10.0.2.2');
    }
    final String portPart = _envPort == '-1' ? '' : ':$_envPort';
    return '$host$portPart$_envPrefix';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  //Recupera gli hotspot calcolati dall'IA
  Future<List<RiskHotspot>> getRiskHotspots() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/risk/hotspots');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((json) => RiskHotspot.fromJson(json)).toList();
      } else {
        throw Exception('Errore caricamento hotspot: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Errore RiskRepository: $e");
      // Ritorna lista vuota in caso di errore per non bloccare la UI
      return [];
    }
  }
}