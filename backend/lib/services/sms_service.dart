import 'dart:io';
import 'dart:math';
import 'package:backend/services/email_service.dart';
import 'package:backend/repositories/user_repository.dart';

class SmsService {
  final EmailService _emailService;
  final UserRepository _userRepository;
  // Per testabilità
  final String? _simulationEmail;

  // Costruttore con Dependency Injection
  SmsService({
    EmailService? emailService,
    UserRepository? userRepository,
    // Per override nei test
    String? simulationEmail,
  }) : _emailService = emailService ?? EmailService(),
       _userRepository = userRepository ?? UserRepository(),
       _simulationEmail =
           simulationEmail ?? Platform.environment['SMS_SIMULATION_EMAIL'];

  String generateOtp() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  Future<void> sendOtp(String telefono, String otp) async {
    // Validazione formato telefono
    final phoneRegex = RegExp(r'^\+[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(telefono)) {
      throw ArgumentError('Formato telefono non valido');
    }

    // Validazione formato OTP
    if (otp.length != 6 || int.tryParse(otp) == null) {
      throw ArgumentError('Formato OTP non valido');
    }

    // Verifica esistenza telefono nel DB
    final user = await _userRepository.findUserByPhone(telefono);
    if (user == null) {
      throw Exception('Numero di telefono non trovato nel sistema');
    }

    // Logica di invio
    if (_simulationEmail != null && _simulationEmail.isNotEmpty) {
      print(' Simulazione SMS: Invio OTP via email a $_simulationEmail');

      await _emailService.send(
        to: _simulationEmail,
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
