import 'dart:convert';
import '../services/VerificationService.dart';
import '../repositories/UserRepository.dart';
import '../services/SmsService.dart';

class VerificationController {
  // Inizializzazione delle dipendenze
  final VerificationService _verificationService = VerificationService(
    UserRepository(),
    SmsService(),
  );

  // Simula la gestione di una richiesta HTTP POST /api/verify/otp
  Future<String> handleVerificationRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> requestData = jsonDecode(requestBodyJson);
      final telefono = requestData['telefono'] as String;
      final otp = requestData['otp'] as String;

      final isVerified = await _verificationService.completePhoneVerification(
        telefono,
        otp,
      );

      if (isVerified) {
        final responseBody = {
          'success': true,
          'message': 'Verifica OTP riuscita. L\'utente è ora attivo.',
        };
        return jsonEncode(responseBody);
      } else {
        final responseBody = {
          'success': false,
          'message': 'Codice OTP non valido o scaduto.',
        };
        return jsonEncode(responseBody);
      }
    } catch (e) {
      final responseBody = {
        'success': false,
        'message': 'Errore durante la verifica: $e',
      };
      return jsonEncode(responseBody);
    }
  }
}
