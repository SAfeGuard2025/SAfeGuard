import 'dart:io';
import 'dart:math';
import 'email_service.dart';

class SmsService {
  final EmailService _emailService = EmailService();

  // Genera un codice OTP a 6 cifre
  String generateOtp() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  // Invia email di simulazione invece di stampare solo su console
  Future<void> sendOtp(String telefono, String otp) async {
    final simulationEmail = Platform.environment['SMS_SIMULATION_EMAIL'];

    if (simulationEmail != null && simulationEmail.isNotEmpty) {
      print(' Simulazione SMS: Invio OTP via email a $simulationEmail');

      await _emailService.send(
        to: simulationEmail,
        subject: 'SIMULAZIONE SMS per $telefono',
        htmlContent:
            '''
          <p>È stato richiesto un SMS per il numero: <strong>$telefono</strong></p>
          <p>Il codice OTP è: <h1>$otp</h1></p>
        ''',
      );
    } else {
      print(
        ' SMS_SIMULATION_EMAIL non impostata. OTP stampato in console: $otp',
      );
    }
  }
}
