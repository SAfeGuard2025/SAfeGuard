import '../repositories/user_repository.dart';
import 'sms_service.dart';

class VerificationService {
  // Dipendenze: Repository per l'accesso al DB e SmsService per l'invio fisico dell'SMS
  final UserRepository _userRepository;
  final SmsService _smsService;

  VerificationService(this._userRepository, this._smsService);

  //Avvia il processo di invio OTP
  Future<void> startPhoneVerification(String telefono) async {
    final otp = _smsService.generateOtp();
    await _userRepository.saveOtp(telefono, otp);
    await _smsService.sendOtp(telefono, otp);
  }

  //Completa la verifica OTP
  Future<bool> completePhoneVerification(String telefono, String otp) async {
    final isOtpValid = await _userRepository.verifyOtp(telefono, otp);

    if (isOtpValid) {
      // Trova l'utente registrato con questo telefono
      final userData = await _userRepository.findUserByPhone(telefono);
      if (userData != null) {
        final email = userData['email'] as String;
        // Aggiorna lo stato nel DB
        await _userRepository.markUserAsVerified(email);
      }
    }
    return isOtpValid;
  }
}
