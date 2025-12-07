import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:dotenv/dotenv.dart'; // Assicurati di avere dotenv caricato

class NotificationService {
  static final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Caricamento Lazy: il client viene creato solo alla prima necessità
  AutoRefreshingAuthClient? _client;
  String? _projectId;

  /// Percorso del file credenziali (meglio metterlo in .env)
  String get _serviceAccountPath =>
      Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'] ?? 'safeguard-service-account.json';

  /// Inizializza e autentica il client Google
  Future<void> _ensureAuth() async {
    if (_client != null) return;

    final file = File(_serviceAccountPath);
    if (!await file.exists()) {
      throw Exception("❌ File credenziali non trovato in: $_serviceAccountPath");
    }

    try {
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      _projectId = jsonData['project_id'];

      final credentials = ServiceAccountCredentials.fromJson(jsonData);
      _client = await clientViaServiceAccount(credentials, _scopes);

      print("✅ FCM Service Authenticated. Project: $_projectId");
    } catch (e) {
      print("❌ Errore autenticazione FCM: $e");
      rethrow;
    }
  }

  /// Invia una notifica broadcast a una lista di token
  Future<void> sendBroadcast({
    required String title,
    required String body,
    required List<String> tokens,
    String type = 'emergency_alert',
  }) async {
    if (tokens.isEmpty) return;

    await _ensureAuth();

    // In produzione, considera l'invio in batch (max 500 per richiesta) o code asincrone
    for (var token in tokens) {
      // Non aspettiamo l'invio (fire-and-forget) per non bloccare il loop
      _sendSingle(title, body, token, type).catchError((e) {
        print("⚠️ Errore invio a $token: $e");
      });
    }
  }

  Future<void> _sendSingle(String title, String body, String token, String type) async {
    if (_client == null) return;

    final uri = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send');

    final message = {
      'message': {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'type': type,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'timestamp': DateTime.now().toIso8601String(),
        },
        'android': {
          // Priorità di consegna del messaggio (risparmio batteria vs velocità)
          'priority': 'HIGH',
          'notification': {
            'channel_id': 'emergency_channel_v3',
            // CORREZIONE: Si chiama 'notification_priority', non 'priority'
            'notification_priority': 'PRIORITY_MAX',
            'default_sound': true,
            'visibility': 'public',
          }
        },
        // Configurazione iOS
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
              'content-available': 1,
            }
          }
        }
      }
    };

    try {
      final response = await _client!.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );

      if (response.statusCode != 200) {
        print("FCM Error (${response.statusCode}): ${response.body}");
      } else {
        print("Notifica inviata con successo a: ...${token.substring(token.length - 6)}");
      }
    } catch (e) {
      print("Errore rete FCM: $e");
    }
  }
}