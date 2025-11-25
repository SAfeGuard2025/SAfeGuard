import 'dart:convert';
import 'dart:io'; // Per Platform.environment
import 'package:crypto/crypto.dart'; // Importa crypto

import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/Utente.dart';
import '../repositories/UserRepository.dart';
import 'VerificationService.dart';

const String rescuerDomain = '@soccorritore.gmail';

class RegisterService {
  final UserRepository _userRepository;
  final VerificationService _verificationService;

  RegisterService(this._userRepository, this._verificationService);

  // Funzione privata per generare l'hash
  String _hashPassword(String password) {
    // 1. Recupera il segreto dalle Env (o usa un fallback per sicurezza in dev)
    final secret = Platform.environment['HASH_SECRET'] ?? 'fallback_secret_dev';

    // 2. Unisce password + segreto
    final bytes = utf8.encode(password + secret);

    // 3. Calcola SHA-256 e restituisce la stringa esadecimale
    return sha256.convert(bytes).toString();
  }

  Future<UtenteGenerico> register(
      Map<String, dynamic> requestData,
      String password,
      ) async {
    final email = requestData['email'] as String?;
    final telefono = requestData['telefono'] as String?;

    if (password.isEmpty || (email == null && telefono == null)) {
      throw Exception('Devi fornire Password e almeno Email o Telefono.');
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

    bool isSoccorritore = false;
    if (email != null) {
      isSoccorritore = email.toLowerCase().endsWith(rescuerDomain);
    }

    final UtenteGenerico newUser;
    if (isSoccorritore) {
      newUser = Soccorritore.fromJson(requestData);
    } else {
      newUser = Utente.fromJson(requestData);
    }

    final savedUser = await _userRepository.saveUser(newUser);

    if (savedUser.telefono != null) {
      await _verificationService.startPhoneVerification(savedUser.telefono!);
    }

    return savedUser;
  }
}