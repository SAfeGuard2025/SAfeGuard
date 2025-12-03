import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:firedart/firedart.dart';

import '../services/email_service.dart';
import '../services/register_service.dart';
import '../services/verification_service.dart';
import '../services/sms_service.dart';
import '../repositories/user_repository.dart';

import 'package:data_models/utente_generico.dart';

class RegisterController {
  // 1. Inizializzazione del RegisterService con le sue dipendenze
  final RegisterService _registerService = RegisterService(
    UserRepository(),
    VerificationService(UserRepository(), SmsService()),
  );

  final Map<String, String> _headers = {'content-type': 'application/json'};

  // Handler per l'API: POST /api/auth/register
  Future<Response> handleRegisterRequest(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _badRequest('Nessun dato inviato');

      final Map<String, dynamic> requestData = jsonDecode(body);

      final email = (requestData['email'] as String?)?.toLowerCase();
      if (email != null) {
        requestData['email'] = email; // Aggiorna la mappa per il Service
      }

      final String? telefono = requestData['telefono'] =
          (requestData['telefono'] as String?)?.replaceAll(' ', '');
      String? password = requestData['password'] as String?;
      final confermaPassword = requestData['confermaPassword'] as String?;

      final nome = requestData['nome'] as String?;
      final cognome = requestData['cognome'] as String?;

      // Rimuove i campi sensibili/temporanei prima di passare i dati al RegisterService
      requestData.remove('password');
      requestData.remove('confermaPassword');

      if ((email == null || email.isEmpty) &&
          (telefono == null || telefono.isEmpty)) {
        return _badRequest('Inserisci Email o Numero di Telefono.');
      }
      //Controlli sul campo Password

      if (password == null || password.isEmpty) {
        return _badRequest('Password obbligatoria.');
      }

      if (password.length < 6 || password.length > 12) {
        return _badRequest(
          'La password deve essere lunga tra 6 e 12 caratteri.',
        );
      }

      // La parte [^a-zA-Z0-9] significa "qualsiasi cosa che non sia alfanumerico"
      // Questo accetta automaticamente trattini, spazi, simboli matematici, ecc.
      if (!RegExp(
        r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9])',
      ).hasMatch(password)) {
        return _badRequest(
          'La password deve contenere almeno: 1 Maiuscola, 1 Numero e 1 Carattere Speciale.',
        );
      }

      if (confermaPassword == null || confermaPassword.isEmpty) {
        return _badRequest('Inserisci la conferma della password.');
      }

      if (password != confermaPassword) {
        return _badRequest('Le password non coincidono');
      }

      if (nome == null || nome.isEmpty || cognome == null || cognome.isEmpty) {
        return _badRequest('Nome e Cognome sono obbligatori.');
      }

      // 2. Chiamata al RegisterService
      // Delega la creazione dell'utente, l'hashing della password e il salvataggio nel DB.
      final UtenteGenerico user = await _registerService.register(
        requestData,
        password,
      );

      // 3. Avvio del processo di verifica (OTP email)
      if (email != null && (telefono == null || telefono.isEmpty)) {
        final String otpCode = _generateOTP();

        // Salva l'OTP nel database in attesa di verifica
        await Firestore.instance
            .collection('email_verifications')
            .document(email)
            .set({
              'otp': otpCode,
              'email': email,
              'created_at': DateTime.now().toIso8601String(),
              'is_verified': false,
            });

        // Invio email reale tramite Resend
        final emailService = EmailService();
        await emailService.send(
          to: email,
          subject: 'Il tuo codice di verifica Safeguard',
          htmlContent: '<p>Il tuo codice di verifica è: <h1>$otpCode</h1></p>',
        );
      }

      // Rimuove l'hash della password prima di inviare i dati utente al frontend
      final responseBody = {
        'success': true,
        'message': 'Registrazione avviata.',
        'user': user.toJson()..remove('passwordHash'),
      };

      return Response.ok(jsonEncode(responseBody), headers: _headers);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      return _badRequest(msg);
    }
  }

  // Helper per costruire risposte di Errore 400 (Bad Request)
  Response _badRequest(String message) {
    return Response.badRequest(
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }

  // Genera un codice OTP a 6 cifre
  String _generateOTP() {
    return (Random().nextInt(900000) + 100000).toString();
  }
}
