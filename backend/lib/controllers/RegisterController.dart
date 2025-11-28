import 'dart:convert';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:firedart/firedart.dart';

import '../services/RegisterService.dart';
import '../services/VerificationService.dart';
import '../services/SmsService.dart';
import '../repositories/UserRepository.dart';

import 'package:data_models/UtenteGenerico.dart';

class RegisterController {
  final RegisterService _registerService = RegisterService(
    UserRepository(),
    VerificationService(UserRepository(), SmsService()),
  );

  final Map<String, String> _headers = {'content-type': 'application/json'};

  Future<Response> handleRegisterRequest(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _badRequest('Nessun dato inviato');

      final Map<String, dynamic> requestData = jsonDecode(body);

      final email = requestData['email'] as String?;
      final telefono = requestData['telefono'] as String?;
      String? password = requestData['password'] as String?;
      final confermaPassword = requestData['confermaPassword'] as String?;

      final nome = requestData['nome'] as String?;
      final cognome = requestData['cognome'] as String?;

      requestData.remove('password');
      requestData.remove('confermaPassword');

      // 1. VALIDAZIONE CAMPI
      if ((email == null || email.isEmpty) && (telefono == null || telefono.isEmpty)) {
        return _badRequest('Inserisci Email o Numero di Telefono.');
      }

      /* Generazione Password fittizia per telefono
      if (telefono != null && (password == null || password.isEmpty)) {
        password = _generateRandomPassword();
      }*/

      if (password == null || password.isEmpty) {
        return _badRequest('Password obbligatoria.');
      }

      if (confermaPassword != null && password != confermaPassword) {
        return _badRequest('Le password non coincidono');
      }

      if (nome == null || nome.isEmpty || cognome == null || cognome.isEmpty) {
        return _badRequest('Nome e Cognome sono obbligatori.');
      }

      // 2. CHIAMATA AL SERVICE
      final UtenteGenerico user = await _registerService.register(requestData, password);

      // 3. OTP EMAIL
      if (email != null && (telefono == null || telefono.isEmpty)) {
        final String otpCode = _generateOTP();
        await Firestore.instance.collection('email_verifications').document(email).set({
          'otp': otpCode,
          'email': email,
          'created_at': DateTime.now().toIso8601String(),
          'is_verified': false,
        });
      }

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

  Response _badRequest(String message) {
    return Response.badRequest(
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }

  String _generateOTP() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  /*String _generateRandomPassword() {
    return 'PhoneUser_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}!';
  }*/
}