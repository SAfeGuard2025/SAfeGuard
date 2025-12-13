import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:data_models/utente_generico.dart';
import 'package:data_models/soccorritore.dart';
import 'package:data_models/utente.dart';
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

    if (telefono != null) {
      // Campo numero lasciato vuoto
      if (telefono.isEmpty) {
        throw Exception('Numero non valido');
      }

      // Numero inserito inferiore a 5 cifre
      if (telefono.length < 5) {
        throw Exception('Numero troppo corto');
      }

      // Numero inserito superiore a 15 cifre
      if (telefono.length > 15) {
        throw Exception('Numero troppo lungo');
      }
    }

    if (email != null) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        throw Exception('Formato email non valido'); // Blocca "ciao", "test@", ecc.
      }
    }

    // 1. Variabile per tracciare se stiamo aggiornando un utente esistente (rinvio OTP)
    bool isUpdate = false;

    if (email != null) {
      final existingUser = await _userRepository.findUserByEmail(email);
      if (existingUser != null) {
        final bool isVerified =
            existingUser['isVerified'] == true ||
            existingUser['attivo'] == true;

        if (isVerified) {
          throw Exception('Utente con questa email è già registrato.');
        } else {
          // Se non è verificato, riusiamo questo ID e segniamo come update
          requestData['id'] = existingUser['id'];
          isUpdate = true;
        }
      }
    }

    // 2. Controllo esistenza per TELEFONO
    // Eseguiamo questo controllo solo se non abbiamo già trovato l'utente via email
    if (!isUpdate && telefono != null) {
      final existingUserPhone = await _userRepository.findUserByPhone(telefono);
      if (existingUserPhone != null) {
        final bool isVerified =
            existingUserPhone['isVerified'] == true ||
            existingUserPhone['attivo'] == true;

        if (isVerified) {
          throw Exception('Utente con questo telefono è già registrato.');
        } else {
          // Trovato utente non verificato con questo telefono: prepariamo l'update
          requestData['id'] = existingUserPhone['id'];
          isUpdate = true;
        }
      }
    }

    // --- Validazione Campi (Rimane invariata) ---
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

    // 3. Validazione Unicità Finale
    // Saltiamo i controlli se è un update (!isUpdate)
    if (!isUpdate &&
        email != null &&
        await _userRepository.findUserByEmail(email) != null) {
      throw Exception('Utente con questa email è già registrato.');
    }

    // Questo ora verrà saltato se abbiamo impostato isUpdate nel punto 2
    if (!isUpdate &&
        telefono != null &&
        await _userRepository.findUserByPhone(telefono) != null) {
      throw Exception('Utente con questo telefono è già registrato.');
    }

    // 3. Preparazione Dati
    // Sostituisce la password in chiaro con l'hash
    requestData['passwordHash'] = _hashPassword(password);

    // Se è un update, manteniamo l'ID esistente, altrimenti 0
    if (!isUpdate) {
      requestData['id'] = 0;
    }

    requestData['isVerified'] = false;
    requestData['attivo'] = false;

    bool isSoccorritore = false;
    if (email != null) {
      isSoccorritore = RescuerConfig.isSoccorritore(email);
    }
    requestData['isSoccorritore'] = isSoccorritore;

    final UtenteGenerico newUser;
    if (isSoccorritore) {
      newUser = Soccorritore.fromJson(requestData);
    } else {
      newUser = Utente.fromJson(requestData);
    }

    final savedUser = await _userRepository.saveUser(newUser);

    // Gestione invio SMS se necessario (Rimane invariato)
    if (savedUser.telefono != null && savedUser.telefono!.isNotEmpty) {
      try {
        await _verificationService.startPhoneVerification(savedUser.telefono!);
      } catch (e) {
        print("Errore durante l'invio dell'SMS: $e");
      }
    }

    // Nota: L'OTP Email viene generato nel Controller, non qui.
    return savedUser;
  }
}
