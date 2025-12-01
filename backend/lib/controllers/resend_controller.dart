import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:firedart/firedart.dart';
import '../services/email_service.dart';
import '../services/sms_service.dart';

// Controller responsabile della gestione delle richieste di rinvio del codice OTP (One-Time Password).
// Gestisce sia il flusso via Email che quello via SMS (o simulazione SMS).
class ResendController {
  // Iniezione dei servizi per l'invio dei messaggi
  final EmailService _emailService = EmailService();
  final SmsService _smsService = SmsService();

  // Header standard per le risposte JSON
  final Map<String, String> _headers = {'content-type': 'application/json'};

  // Gestisce la richiesta HTTP POST per rinviare il codice.
  Future<Response> handleResendRequest(Request request) async {
    try {
      // 1. Lettura del corpo della richiesta
      final String body = await request.readAsString();
      if (body.isEmpty) return _badRequest('Body vuoto');

      // 2. Parsing e Pulizia dei dati
      final Map<String, dynamic> data = jsonDecode(body);
      final String? email = (data['email'] as String?)?.trim().toLowerCase();

      // Rimuove eventuali spazi nel numero di telefono per uniformità
      final String? telefono = (data['telefono'] as String?)?.replaceAll(
        ' ',
        '',
      );

      // 3. Validazione: Almeno un metodo di contatto deve essere presente
      if (email == null && telefono == null) {
        return _badRequest('Email o Telefono richiesti per il rinvio.');
      }

      // 4. Generazione di un nuovo codice OTP a 6 cifre
      final String newOtp = (Random().nextInt(900000) + 100000).toString();

      // --- LOGICA EMAIL ---
      if (email != null) {
        // Aggiorna o Crea il documento OTP nella collezione 'email_verifications'
        // Questo sovrascrive il vecchio codice se ne esisteva uno
        await Firestore.instance
            .collection('email_verifications')
            .document(email)
            .set({
              'otp': newOtp,
              'email': email,
              'created_at': DateTime.now()
                  .toIso8601String(), // Timestamp per scadenza futura
              'is_verified': false,
            });

        // Utilizza il servizio Email per inviare il codice all'utente
        await _emailService.send(
          to: email,
          subject: 'Nuovo codice di verifica Safeguard',
          htmlContent:
              '<p>Il tuo nuovo codice di verifica è: <h1>$newOtp</h1></p>',
        );
      }
      // --- LOGICA SMS (Simulazione) ---
      else if (telefono != null) {
        // Aggiorna o Crea il documento OTP nella collezione 'phone_verifications'
        await Firestore.instance
            .collection('phone_verifications')
            .document(telefono)
            .set({
              'otp': newOtp,
              'telefono': telefono,
              'created_at': DateTime.now().toIso8601String(),
            });

        // Invia la simulazione SMS (l'OTP arriva all'email configurata nel .env)
        await _smsService.sendOtp(telefono, newOtp);
      }

      // 5. Risposta di successo al client
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Codice OTP rinviato con successo.',
        }),
        headers: _headers,
      );
    } catch (e) {
      // Gestione errori server (es. DB non raggiungibile, errore API email)
      print("Errore nel rinvio OTP: $e");
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Errore server: $e'}),
        headers: _headers,
      );
    }
  }

  // Helper per costruire risposte HTTP 400 (Bad Request) standardizzate
  Response _badRequest(String msg) {
    return Response.badRequest(
      body: jsonEncode({'success': false, 'message': msg}),
      headers: _headers,
    );
  }
}
