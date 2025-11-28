import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/Utente.dart';
import '../repositories/UserRepository.dart';
import 'VerificationService.dart';

const List<String> rescuerDomains = [
  '@soccorritore.gmail',
  '@crocerossa.it',
  '@118.it',
  '@protezionecivile.it',
];

class RegisterService {
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

    // 1. Validazione: Almeno uno dei due deve esistere
    if (password.isEmpty || (email == null && telefono == null)) {
      throw Exception('Devi fornire Password e almeno Email o Telefono.');
    }

    if (nome == null || cognome == null) {
      throw Exception('Nome e Cognome sono obbligatori.');
    }

    if (email != null && await _userRepository.findUserByEmail(email) != null) {
      throw Exception('Utente con questa email è già registrato.');
    }
    if (telefono != null && await _userRepository.findUserByPhone(telefono) != null) {
      throw Exception('Utente con questo telefono è già registrato.');
    }

    // Invece di salvare la password in chiaro, salviamo l'hash
    requestData['passwordHash'] = _hashPassword(password);

    requestData['id'] = 0;
    requestData['isVerified'] = false;
    requestData['attivo'] = false;

    bool isSoccorritore = false;
    if (email != null) {
      isSoccorritore = rescuerDomains.any((domain) => email.toLowerCase().endsWith(domain));
    }
    requestData['isSoccorritore'] = isSoccorritore;

    // 5. Creazione Oggetto
    final UtenteGenerico newUser;
    if (isSoccorritore) {
      newUser = Soccorritore.fromJson(requestData);
    } else {
      newUser = Utente.fromJson(requestData);
    }

    // 6. Salvataggio
    final savedUser = await _userRepository.saveUser(newUser);

    // 7. Avvio Verifica Telefono (se presente)
    if (savedUser.telefono != null && savedUser.telefono!.isNotEmpty) {
      try {
        await _verificationService.startPhoneVerification(savedUser.telefono!);
      } catch (e) {
        print("Errore durante l'invio dell'SMS: $e");
      }
    }

    return savedUser;
  }
}