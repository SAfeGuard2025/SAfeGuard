import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:path/path.dart' as path_lib;

class NotificationService {

  final String _serviceAccountPath;
  final String _projectId ;

  AccessCredentials? _credentials;

  // Costruttore per inizializzare il percorso
  NotificationService() :
  // Risolve l'ID Progetto
        _projectId = "safeguard-c08",
  // Risolve il percorso, assumendo che il file sia in backend
        _serviceAccountPath = path_lib.join(
            Directory.current.path,
            "safeguard-c08-e1861c983cab.json"
        );

  /// Ottiene il Token di accesso da Google
  Future<String?> _getAccessToken() async {
    try {
      if (_credentials != null &&
          _credentials!.accessToken.expiry.isAfter(DateTime.now())) {
        return _credentials!.accessToken.data;
      }

      final content = await File(_serviceAccountPath).readAsString();
      final accountCredentials = ServiceAccountCredentials.fromJson(content);

      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      _credentials = client.credentials;
      client.close();

      return _credentials!.accessToken.data;
    } catch (e) {
      print('❌ Errore Auth Google: $e');
      return null;
    }
  }

  /// Invia la notifica
  Future<void> sendNotificationToTokens(
    List<String> tokens,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    if (tokens.isEmpty) return;

    final String? accessToken = await _getAccessToken();
    if (accessToken == null) return;

    final Uri url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send',
    );

    print('📨 Invio notifica a ${tokens.length} utenti...');

    for (String token in tokens) {
      try {
        final messagePayload = {
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            // Converte tutti i valori in stringhe per evitare errori FCM
            'data': data.map((key, value) => MapEntry(key, value.toString())),
            'android': {
              'priority': 'high',
              'notification': {'channel_id': 'high_importance_channel'},
            },
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
        }
      } catch (e) {
        print('❌ Eccezione invio: $e');
      }
    }
    print('✅ Processo invio terminato.');
  }
}
