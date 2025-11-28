import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Serve per kIsWeb
import 'package:http/http.dart' as http;

class AuthRepository {

  String get _baseUrl {
    String host = 'http://localhost';
    if (!kIsWeb && Platform.isAndroid) {
      host = 'http://10.0.2.2';
    }
    return '$host:8080';
  }

  // --- LOGIN EMAIL/PASSWORD ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        throw Exception(body['message'] ?? "Errore durante il login");
      }
    } catch (e) {
      throw Exception("Errore di connessione: $e");
    }
  }

  // --- REGISTRAZIONE EMAIL ---
  Future<void> register(String email, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/register'); // Usa _baseUrl

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'confermaPassword': password, // AGGIUNGI QUESTO
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Errore registrazione");
      }
    } catch (e) {
      throw Exception("Errore di connessione: $e");
    }
  }

  // --- INVIO OTP TELEFONO ---
  // Usa l'endpoint di registrazione perché il tuo RegisterController gestisce anche il solo telefono
  Future<void> sendPhoneOtp(String phoneNumber) async {
    final url = Uri.parse('$_baseUrl/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telefono': phoneNumber,
          // Non mandiamo password, il backend la genera random per il DB
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Errore invio SMS");
      }
    } catch (e) {
      throw Exception("Errore connessione: $e");
    }
  }

  // --- VERIFICA OTP (Unificata) ---
  // Restituisce una Map perché in caso di telefono potremmo ricevere il token login
  Future<Map<String, dynamic>> verifyOtp({String? email, String? phone, required String code}) async {
    final url = Uri.parse('$_baseUrl/api/verify');

    // Costruiamo il body dinamico
    final Map<String, dynamic> requestBody = {'code': code};
    if (email != null) requestBody['email'] = email;
    if (phone != null) requestBody['telefono'] = phone;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body;
      } else {
        throw Exception(body['message'] ?? "Codice non valido");
      }
    } catch (e) {
      throw Exception("Errore verifica: $e");
    }
  }
}