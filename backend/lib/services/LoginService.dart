import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import '../repositories/UserRepository.dart';
import 'JWTService.dart'; // Assumi che JWTService sia disponibile e corretto

// Dominio speciale per i soccorritori da modificare poi
const String rescuerDomain = '@soccorritore.com';

class LoginService {
  final UserRepository _userRepository = UserRepository();
  final JWTService _jwtService = JWTService(); // ⭐️ Inietta la dipendenza JWT

  // SIMULAZIONE: In un ambiente reale, useremmo una libreria come 'bcrypt'
  bool _verifyPassword(String providedPassword, String storedHash) {
    // Per la simulazione, controlliamo solo l'hash simulato
    return providedPassword == storedHash;
  }

  // Logica principale del Login
  // ⭐️ MODIFICATO: Ora restituisce Map<String, dynamic>? che include l'utente e il token
  Future<Map<String, dynamic>?> login({
    String? email,
    String? telefono,
    required String password,
  }) async {
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

    final UtenteGenerico user;
    final String userType;

    if (finalEmail.toLowerCase().endsWith(rescuerDomain)) {
      user = Soccorritore.fromJson(userData);
      userType = 'Soccorritore';
    } else {
      user = Utente.fromJson(userData);
      userType = 'Utente';
    }

    // Se il login ha successo, genera il Token JWT
    // Assicurati che l'utente sia verificato se la logica lo richiede (e.g., if (user.isVerified))

    final token = _jwtService.generateToken(user.id!, userType);

    // RESTITUISCI L'UTENTE E IL TOKEN
    return {'user': user, 'token': token};
  }
}
