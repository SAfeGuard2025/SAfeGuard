import 'dart:convert';

import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import '../repositories/UserRepository.dart';
import 'JWTService.dart';

import 'package:http/http.dart' as http;

// Dominio speciale per i soccorritori da modificare poi
const String rescuerDomain = '@soccorritore.com';

class LoginService {
  final UserRepository _userRepository = UserRepository();
  final JWTService _jwtService = JWTService();

  // SIMULAZIONE: In un ambiente reale, useremmo una libreria come 'bcrypt'
  bool _verifyPassword(String providedPassword, String storedHash) {
    // Per la simulazione, controlliamo solo l'hash simulato
    return providedPassword == storedHash;
  }

  // --- NUOVA FUNZIONE: Login con Google ---
  Future<Map<String, dynamic>?> loginWithGoogle(String googleIdToken) async {
    // 1. Verifica del Token Google
    // Chiamiamo l'endpoint di Google per validare l'idToken ricevuto dal frontend
    final verifyUrl = Uri.parse(
      'https://oauth2.googleapis.com/tokeninfo?id_token=$googleIdToken',
    );

    final response = await http.get(verifyUrl);

    if (response.statusCode != 200) {
      throw Exception('Token Google non valido o scaduto.');
    }

    // 2. Estrazione Dati Utente dal Token
    final payload = jsonDecode(response.body);

    final String email = payload['email'];
    final String? name = payload['name'];

    // 3. Controllo esistenza utente nel Database
    Map<String, dynamic>? userData = await _userRepository.findUserByEmail(
      email,
    );

    UtenteGenerico user;
    String userType;

    // Determina il tipo in base al dominio (logica condivisa)
    final isSoccorritore = email.toLowerCase().endsWith(rescuerDomain);
    userType = isSoccorritore ? 'Soccorritore' : 'Utente';

    if (userData != null) {
      // CASO A: L'utente esiste già
      userData.remove('passwordHash'); // Pulizia sicurezza

      if (isSoccorritore) {
        user = Soccorritore.fromJson(userData);
      } else {
        user = Utente.fromJson(userData);
      }

      // Opzionale: Aggiornare foto profilo o nome se cambiati su Google
      // await _userRepository.updateUserField(user.id!, 'fotoProfilo', picture);
    } else {
      // Primo accesso (Registrazione Automatica)
      // Creiamo l'oggetto utente.
      // Poiché è Google, non c'è passwordHash.

      final newUserMap = {
        'email': email,
        'nome': name ?? 'Utente Google',
        'telefono': null,
        'passwordHash': '', // O null, da gestire nel DataModel
        'dataRegistrazione': DateTime.now().toIso8601String(),
      };

      // Salva nel DB tramite Repository
      final createdUserData = await _userRepository.createUser(
        newUserMap,
        collection: userType,
      );

      if (isSoccorritore) {
        user = Soccorritore.fromJson(createdUserData);
      } else {
        user = Utente.fromJson(createdUserData);
      }
    }

    // 4. Generazione del Token JWT (Sessione interna)
    final token = _jwtService.generateToken(user.id!, userType);

    return {'user': user, 'token': token};
  }

  // Logica principale del Login
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
    if (storedHash.isEmpty) {
      // Se l'utente si è registrato con Google, potrebbe non avere password
      throw Exception('Questo utente deve accedere tramite Google.');
    }

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

    // Restituisce l'utente e il token
    return {'user': user, 'token': token};
  }
}
