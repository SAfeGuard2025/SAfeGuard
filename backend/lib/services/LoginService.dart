import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import '../repositories/UserRepository.dart';

// Dominio speciale per i soccorritori da modificare poi
const String _RESCUER_DOMAIN = '@soccorritore.com';

class LoginService {
  final UserRepository _userRepository = UserRepository();
  // SIMULAZIONE: In un ambiente reale, useremmo una libreria come 'bcrypt'
  // per eseguire l'hashing e la verifica in modo sicuro.
  bool _verifyPassword(String providedPassword, String storedHash) {
    // Esempio: return bcrypt.checkpw(providedPassword, storedHash);
    // Per la simulazione, controlliamo solo l'hash simulato
    return providedPassword == storedHash;
  }

  // Logica principale del Login
  Future<UtenteGenerico?> login({String? email, String? telefono, required String password}) async {
    // Pre-validazione
    if (email == null && telefono == null) {
      throw ArgumentError('Devi fornire email o telefono per il login.');
    }

    Map<String, dynamic>? userData;
    String finalEmail = '';

    // 1. Tenta il login tramite EMAIL
    if (email != null) {
      userData = await _userRepository.findUserByEmail(email);
      if (userData != null) {
        finalEmail = email;
      }
    }

    // 2. Se l'email fallisce (o non è stata fornita), tenta il login tramite TELEFONO
    if (userData == null && telefono != null) {
      userData = await _userRepository.findUserByPhone(telefono);
      if (userData != null) {
        finalEmail = userData['email'] as String; // Recupera l'email dal DB
      }
    }

    if (userData == null) {
      // Utente non trovato in nessuno dei due modi
      return null;
    }

    final storedHash = userData['passwordHash'] as String;

    // 3. Verifica della Password
    if (!_verifyPassword(password, storedHash)) {
      return null;
    }

    // 4. Determina il tipo di Utente e deserializza
    userData.remove('passwordHash');

    if (finalEmail.toLowerCase().endsWith(_RESCUER_DOMAIN)) {
      return Soccorritore.fromJson(userData);
    } else {
      return Utente.fromJson(userData);
    }
  }
}