import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart'; // Assicurati di importare questo pacchetto

class EmailService {
  // Carica le variabili dal file .env
  static final _env = DotEnv(includePlatformEnvironment: true)..load();

  // Recupera la chiave dando priorità al file .env
  String get _apiKey => _env['RESEND_API_KEY'] ?? '';

  String get _sender => 'Safeguard <noreply@safeguard.masone.cloud>';

  Future<void> send({
    required String to,
    required String subject,
    required String htmlContent,
  }) async {
    if (_apiKey.isEmpty) {
      print(
        ' ERRORE CRITICO: RESEND_API_KEY non trovata. Controlla il file .env',
      );
      return;
    }

    try {
      final url = Uri.parse('https://api.resend.com/emails');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': _sender,
          'to': [to],
          'subject': subject,
          'html': htmlContent,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(' Email inviata correttamente a $to');
      } else {
        print(' Errore API Resend (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print(' Eccezione durante invio email: $e');
    }
  }
}
