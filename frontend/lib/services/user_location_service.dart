import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserLocationService {
  // Costruisce l'URL base gestendo l'emulatore Android
  String get _baseUrl {
    String host = 'http://localhost';
    if (!kIsWeb && Platform.isAndroid) {
      host = 'http://10.0.2.2'; // IP speciale per emulatore Android
    }
    // NOTA: In output.txt il server gira sulla porta 8080
    return '$host:8080/api';
  }

  // Metodo per INVIARE la posizione
  Future<void> sendLocationUpdate(String jwtToken) async {
    print("🚀 [UserLocationService] Avvio aggiornamento posizione...");
    try {
      // 1. Controlla Permessi GPS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("⛔ Permesso GPS negato.");
          return;
        }
      }

      // 2. Prendi coordinate GPS
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );
      print("📍 GPS Preso: ${position.latitude}, ${position.longitude}");

      // 3. Prendi Token Notifiche
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      // 4. DEFINIZIONE URL (FONDAMENTALE)
      // Nel tuo server.dart: app.mount('/api/emergency', EmergencyController().router);
      // Nel tuo emergency_controller.dart: router.patch('/location', ...);
      // QUINDI L'URL È:
      final url = Uri.parse('$_baseUrl/emergency/location');

      print("📡 Invio dati a: $url");

      // 5. Chiamata al Server
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken', // Il token JWT dell'utente loggato
        },
        body: jsonEncode({
          'lat': position.latitude,
          'lng': position.longitude, // Attenzione: lng, non lon (dipende dal tuo backend)
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Posizione aggiornata con successo nel DB!");
      } else {
        print("❌ Errore Backend (${response.statusCode}): ${response.body}");
      }

    } catch (e) {
      print("🔥 Errore connessione servizio posizione: $e");
    }
  }
}