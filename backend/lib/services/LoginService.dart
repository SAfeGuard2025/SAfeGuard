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
    if (storedHash == 'hashed_password_for_user' && providedPassword == 'password123') {
      return true;
    }
    if (storedHash == 'hashed_password_for_rescue' && providedPassword == 'password456') {
      return true;
    }
    return false;
  }

  // Logica principale del Login
  Future<UtenteGenerico?> login(String email, String password) async {
    final userData = await _userRepository.findUserByEmail(email);

    if (userData == null) {   // Utente non trovato
      return null;
    }

    final storedHash = userData['passwordHash'] as String;

    // 1. Verifica della Password
    if (!_verifyPassword(password, storedHash)) { // Password errata
      return null;
    }

    // Nota: L'hash NON viene incluso nell'oggetto che ritorna

    // Rimuovi l'hash prima della deserializzazione per la sicurezza
    userData.remove('passwordHash');

    // 2. Determina il tipo di Utente e Deserializza
    if (email.toLowerCase().endsWith(_RESCUER_DOMAIN)) {
      // Se l'email finisce con il dominio speciale, è un Soccorritore
      return Soccorritore.fromJson(userData);
    } else {
      // Altrimenti, è un Utente standard
      return Utente.fromJson(userData);
    }
  }
}