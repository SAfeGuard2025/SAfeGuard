// File: backend/lib/services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // Per accedere alle variabili d'ambiente (FCM_SERVER_KEY)

class NotificationService {
  // Legge la chiave segreta FCM dalle variabili d'ambiente (es. .env file)
  final String _fcmServerKey = Platform.environment['FCM_SERVER_KEY'] ?? 'FALLBACK_KEY_INVALID';

  // L'URL dell'API di Google FCM
  final Uri _fcmUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

  /// Invia una notifica a una lista di token (push massive).
  Future<void> sendNotificationToTokens(
      List<String> tokens, String title, String body, Map<String, dynamic> data) async {

    // Controlli di sicurezza e configurazione
    if (tokens.isEmpty || _fcmServerKey == 'FALLBACK_KEY_INVALID') {
      print('❌ Errore: Token mancanti o chiave FCM non configurata (FCM_SERVER_KEY).');
      return;
    }

    // Rimuovi i token duplicati (se un soccorritore è anche vicino)
    final uniqueTokens = tokens.toSet().toList();

    final response = await http.post(
      _fcmUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$_fcmServerKey', // Uso della chiave segreta
      },
      body: jsonEncode({
        'registration_ids': uniqueTokens, // Invia a una lista di token
        'notification': {
          'title': title,
          'body': body,
          'sound': 'default',
        },
        'data': data, // Dati aggiuntivi (come l'ID SOS)
      }),
    );

    if (response.statusCode != 200) {
      print('❌ Errore critico invio FCM: Status ${response.statusCode}. Body: ${response.body}');
    } else {
      print('✅ Notifiche FCM inviate con successo a ${uniqueTokens.length} dispositivi.');
    }
  }
}