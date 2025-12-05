import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path_lib;

class NotificationService {

  // 💡 AGGIORNA QUESTI VALORI se sono diversi
  final String _projectId = "safeguard-c08";
  // Assicurati che questo sia il NOME ESATTO del file JSON che hai salvato
  final String _serviceAccountFileName = "safeguard-c08-e1861c983cab.json";

  late String _serviceAccountPath;
  AccessCredentials? _credentials;

  NotificationService() {
    // 2. Assegna il percorso nel CORPO del costruttore.
    _serviceAccountPath = path_lib.join(
        Directory.current.path,
        _serviceAccountFileName
    );
  }

  /// Ottiene il Token di accesso da Google
  Future<String?> _getAccessToken() async {
    try {
      // 1. Verifica se le credenziali esistono e sono ancora valide
      if (_credentials != null &&
          _credentials!.accessToken.expiry.isAfter(DateTime.now())) {
        return _credentials!.accessToken.data;
      }

      // 2. Carica le credenziali del Service Account dal file
      final content = await File(_serviceAccountPath).readAsString();
      final accountCredentials = ServiceAccountCredentials.fromJson(content);

      // 3. Richiedi l'accesso all'API Firebase Messaging
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      _credentials = client.credentials;
      client.close();

      return _credentials!.accessToken.data;
    } catch (e) {
      print('❌ Errore Auth Google con FCM: $e');
      return null;
    }
  }

  /// 📤 Invia la notifica push
  Future<void> sendNotificationToTokens(
      List<String> tokens,
      String title,
      String body,
      Map<String, dynamic> data,
      ) async {
    if (tokens.isEmpty) {
      print('Nessun token destinatario. Invio annullato.');
      return;
    }

    final String? accessToken = await _getAccessToken();
    if (accessToken == null) {
      print('Impossibile ottenere l\'access token. Invio fallito.');
      return;
    }

    final Uri url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
    );

    // Inviamo i messaggi in parallelo (o in batch, se superiamo il limite di 500)
    for (String token in tokens) {
      try {
        final messagePayload = {
          'message': {
            'token': token,
            // 🛎️ Parte NOTIFICATION (mostrata dall'OS)
            'notification': {'title': title, 'body': body},
            // 📦 Parte DATA (gestita dall'app, cruciale per la logica di emergenza)
            'data': data.map((key, value) => MapEntry(key, value.toString())),

            // Impostazioni specifiche Android
            'android': {
              'priority': 'high',
              // Importante per Android 8.0+
              'notification': {'channel_id': 'high_importance_channel'},
            },
            // Impostazioni specifiche iOS
            'apns': {
              'headers': {'apns-priority': '10'},
              'payload': {
                'aps': {
                  'content-available': 1, // Per messaggi in background
                  'alert': {'title': title, 'body': body}
                }
              }
            }
          },
        };

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode(messagePayload),
        );

        if (response.statusCode != 200) {
          print('⚠️ Errore invio token $token: ${response.body}');
        } else {
          // print('Notifica inviata a token $token con successo.');
        }
      } catch (e) {
        print('❌ Eccezione invio: $e');
      }
    }
  }
}