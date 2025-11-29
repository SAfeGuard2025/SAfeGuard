import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/Utente.dart';
import '../config/rescuer_config.dart';
import '../repositories/user_repository.dart';
import 'verification_service.dart';

class RegisterService {
  // Dipendenze: Repository per il DB e Service per la verifica
  final UserRepository _userRepository;
  final VerificationService _verificationService;

  RegisterService(this._userRepository, this._verificationService);

  String _hashPassword(String password) {
    final secret = Platform.environment['HASH_SECRET'] ?? 'fallback_secret_dev';
    final bytes = utf8.encode(password + secret);
    return sha256.convert(bytes).toString();
  }

  Future<UtenteGenerico> register(
    Map<String, dynamic> requestData,
    String password,
  ) async {
    final email = requestData['email'] as String?;
    final telefono = requestData['telefono'] as String?;
    final nome = requestData['nome'] as String?;
    final cognome = requestData['cognome'] as String?;

    // 1. Validazione Campi
    if (password.isEmpty || (email == null && telefono == null)) {
      throw Exception('Devi fornire Password e almeno Email o Telefono.');
    }

    if (nome == null || cognome == null) {
      throw Exception('Nome e Cognome sono obbligatori.');
    }
    if (password.isEmpty) {
      throw Exception('Password obbligatoria.');
    }

    // Lunghezza 6-12
    if (password.length < 6 || password.length > 12) {
      throw Exception('La password deve essere lunga tra 6 e 12 caratteri.');
    }

    // Complessità (Maiuscola + Numero + Speciale)
    if (!RegExp(
      r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?":{}|<>_])',
    ).hasMatch(password)) {
      throw Exception(
        'La password non rispetta i criteri di sicurezza (Maiuscola, Numero, Speciale).',
      );
    }

    // 2. Validazione Unicità
    // Controlla se l'email o il telefono sono già registrati nel DataBase
    if (email != null && await _userRepository.findUserByEmail(email) != null) {
      throw Exception('Utente con questa email è già registrato.');
    }
    if (telefono != null &&
        await _userRepository.findUserByPhone(telefono) != null) {
      throw Exception('Utente con questo telefono è già registrato.');
    }

    // 3. Preparazione Dati
    // Sostituisce la password in chiaro con l'hash
    requestData['passwordHash'] = _hashPassword(password);

    // Imposta campi di stato iniziali
    requestData['id'] = 0;
    requestData['isVerified'] = false;
    requestData['attivo'] = false;

    // 4. Classificazione Utente
    bool isSoccorritore = false;
    if (email != null) {
      isSoccorritore = RescuerConfig.isSoccorritore(email);
    }
    requestData['isSoccorritore'] = isSoccorritore;

    // 5. Creazione Oggetto Modello
    final UtenteGenerico newUser;
    if (isSoccorritore) {
      newUser = Soccorritore.fromJson(requestData);
    } else {
      newUser = Utente.fromJson(requestData);
    }

    // 6. Salvataggio nel DataBase
    final savedUser = await _userRepository.saveUser(newUser);

    // 7. Avvio Verifica Telefono (se presente)
    if (savedUser.telefono != null && savedUser.telefono!.isNotEmpty) {
      try {
        // Delega al VerificationService l'invio dell'OTP
        await _verificationService.startPhoneVerification(savedUser.telefono!);
      } catch (e) {
        // Registra l'errore SMS, ma non blocca la registrazione (l'utente può riprovare)
        print("Errore durante l'invio dell'SMS: $e");
      }
    }

    return savedUser;
  }
}
