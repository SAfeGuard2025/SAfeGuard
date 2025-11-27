import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthRepository {

  static const String baseUrl = "http://10.0.2.2:8080";

  /// Simula il Login con Email e Password
  /// In futuro qui userai: http.post('api/login', body: {...})
  Future<void> login(String email, String password) async {
    // 1. Simuliamo l'attesa della rete (2 secondi)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Simuliamo un controllo (Backend finto)
    // Se l'email contiene "error", lanciamo un'eccezione per testare i messaggi rossi in UI
    if (email.contains("error")) {
      throw Exception("Credenziali non valide");
    }

    // Se tutto va bene, la funzione finisce senza errori (Successo)
    return;
  }

  /// Registrazione: Chiama /api/auth/register definita in server.dart
  Future<void> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

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

      print(response.statusCode);
      print(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Errore registrazione");
      }
      // Se 200/201, successo.
    } catch (e) {
      throw Exception("Errore di connessione: $e");
    }
  }

  /// Simula l'invio del codice SMS (OTP)
  Future<void> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 1));
    // Qui chiameresti l'endpoint per inviare l'SMS reale
    return;
  }

  /// Simula la verifica del codice OTP inserito
  Future<bool> verifyOtp(String email, String code) async {
    final url = Uri.parse('$baseUrl/api/verify');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email, // Ora usiamo l'email passata come argomento
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception("Errore verifica: $e");
    }
  }
}