import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Per kIsWeb

class ProfileRepository {
  // Configurazione URL dinamica come nel tuo AuthRepository
  String get _baseUrl {
    String host = 'http://localhost';
    if (!kIsWeb && Platform.isAndroid) {
      host = 'http://10.0.2.2';
    }
    return '$host:8080';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- GET ALLERGIE (Dal profilo utente) ---
  Future<List<String>> fetchAllergies() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/'); // Prende tutto il profilo

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assumiamo che il backend ritorni l'oggetto Utente con la lista 'allergie'
      return List<String>.from(data['allergie'] ?? []);
    } else {
      throw Exception('Impossibile caricare le allergie');
    }
  }

  // --- AGGIUNGI ALLERGIA ---
  Future<void> addAllergia(String allergia) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/allergie');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'allergia': allergia}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Errore aggiunta allergia: ${response.body}');
    }
  }

  // --- RIMUOVI ALLERGIA ---
  Future<void> removeAllergia(String allergia) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/allergie');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'allergia': allergia}),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore rimozione allergia');
    }
  }
}