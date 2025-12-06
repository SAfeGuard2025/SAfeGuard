import 'dart:convert';
import 'dart:io'; // Necessario per leggere il file
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart'; // Per l'autenticazione OAuth2

class NotificationService {
  // Scope necessari per inviare messaggi tramite FCM
  final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Nome del file JSON scaricato da Firebase
  final String _serviceAccountPath = 'safeguard-c08-e1861c983cab.json';

  // Cache per il token e il client per evitare di rileggere il file a ogni invio
  AutoRefreshingAuthClient? _client;
  String? _projectId;

  /// Inizializza il client autenticato se non esiste già
  Future<void> _initializeClient() async {
    if (_client != null) return;

    try {
      final file = File(_serviceAccountPath);
      if (!await file.exists()) {
        throw Exception("File $_serviceAccountPath non trovato. Assicurati di averlo scaricato da Firebase e messo nella root.");
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);

      // Estrai il Project ID direttamente dal JSON per costruire l'URL
      _projectId = jsonData['project_id'];

      final credentials = ServiceAccountCredentials.fromJson(jsonData);

      // Crea un client che rinfresca automaticamente il token quando scade
      _client = await clientViaServiceAccount(credentials, _scopes);

      print("✅ NotificationService: Autenticazione Service Account riuscita per il progetto: $_projectId");
    } catch (e) {
      print("❌ NotificationService: Errore inizializzazione credenziali: $e");
      rethrow;
    }
  }

  /// Invia notifica a una lista di token
  Future<void> sendBroadcastNotification(String title, String body, List<String> tokens) async {
    if (tokens.isEmpty) return;

    // Assicurati che il client sia pronto
    await _initializeClient();

    // Invia a ogni token (in produzione considera l'invio batch/multicast se i numeri sono alti)
    for (var token in tokens) {
      await _sendSingle(title, body, token);
    }
  }

  /// Invia la singola notifica usando l'API v1 HTTP di Firebase
  Future<void> _sendSingle(String title, String bodyText, String token) async {
    if (_client == null || _projectId == null) {
      print("❌ Errore: Client non inizializzato.");
      return;
    }

    // URL dinamico basato sul project_id estratto dal JSON
    final Uri url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send'
    );

    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': bodyText,
        },
        // Data payload per gestire il click nell'app Flutter
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'emergency_alert',
          'timestamp': DateTime.now().toIso8601String(),
        },
        // Configurazioni specifiche Android (opzionale ma consigliato per priorità alta)
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': 'emergency_channel', // Deve coincidere con quello creato in Flutter
          }
        }
      }
    };

    try {
      // Usiamo _client invece di http standard perché _client inietta automaticamente
      // l'header 'Authorization: Bearer <token>' e lo rinnova se scaduto.
      final response = await _client!.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("📨 Notifica inviata a: ${token.substring(0, 10)}...");
      } else {
        print("⚠️ Errore invio FCM (${response.statusCode}): ${response.body}");
        // Se il token non è più valido (es. app disinstallata), qui dovresti rimuoverlo dal DB
        if (response.body.contains("UNREGISTERED") || response.body.contains("INVALID_ARGUMENT")) {
          print("   -> Token invalido, andrebbe rimosso dal DB.");
        }
      }
    } catch (e) {
      print("❌ Eccezione durante l'invio HTTP: $e");
    }
  }

  // Chiude il client quando il server si spegne (opzionale)
  void close() {
    _client?.close();
  }
}