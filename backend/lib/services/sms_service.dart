import 'dart:math';

class SmsService {
  // Genera un codice OTP a 6 cifre
  String generateOtp() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  // Simula l'invio dell'SMS
  Future<void> sendOtp(String telefono, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    print('--------------------------------------------------');
    print('SMS INVIATO a $telefono. Codice OTP: $otp');
    print('--------------------------------------------------');
  }
}
