import '../repositories/user_repository.dart';
import 'sms_service.dart';

class VerificationService {
  // Dipendenze
  final UserRepository _userRepository;
  final SmsService _smsService;

  // Costruttore con Dependency Injection opzionale
  // Se non vengono passati, usa le istanze reali di default.
  VerificationService([UserRepository? userRepository, SmsService? smsService])
    : _userRepository = userRepository ?? UserRepository(),
      _smsService = smsService ?? SmsService();

  // Avvia il processo di invio OTP
  Future<void> startPhoneVerification(String telefono) async {
    final otp = _smsService.generateOtp();
    await _userRepository.saveOtp(telefono, otp);
    await _smsService.sendOtp(telefono, otp);
  }

  // Completa la verifica OTP
  Future<bool> completePhoneVerification(String telefono, String otp) async {
    // Verifica validità OTP
    final isOtpValid = await _userRepository.verifyOtp(telefono, otp);

    if (isOtpValid) {
      // Cerca l'utente associato al telefono
      final userData = await _userRepository.findUserByPhone(telefono);

      if (userData != null) {
        final email = userData['email'] as String;
        // Aggiorna lo stato (Verificato) nel DB
        await _userRepository.markUserAsVerified(email);
      }
    }
    return isOtpValid;
  }
}
