import 'dart:convert';
import 'dart:io';
// Per Platform.environment
import 'package:crypto/crypto.dart'; // Importa crypto
import 'package:http/http.dart' as http;

import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import '../repositories/UserRepository.dart';
import 'JWTService.dart';

// LISTA DOMINI SOCCORRITORI (Allineata con RegisterService)
const List<String> rescuerDomains = [
  '@soccorritore.com',
  '@soccorritore.gmail',
  '@crocerossa.it',
  '@118.it',
  '@protezionecivile.it',
];

class LoginService {
  final UserRepository _userRepository = UserRepository();
  final JWTService _jwtService = JWTService();

  // Funzione privata per generare l'hash
  String _hashPassword(String password) {
    final secret = Platform.environment['HASH_SECRET'] ?? 'fallback_secret_dev';
    final bytes = utf8.encode(password + secret);
    return sha256.convert(bytes).toString();
  }

  bool _verifyPassword(String providedPassword, String storedHash) {
    final generatedHash = _hashPassword(providedPassword);
    return generatedHash == storedHash;
  }

  // Helper per verificare se un'email appartiene a un soccorritore
  bool _isSoccorritore(String email) {
    return rescuerDomains.any((domain) => email.toLowerCase().endsWith(domain));
  }

  // Login con Google
  Future<Map<String, dynamic>?> loginWithGoogle(String googleIdToken) async {
    // 1. Verifica del Token Google
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

// Google fornisce spesso 'given_name' e 'family_name'
    final String? firstName = payload['given_name'];
    final String? lastName = payload['family_name'];
// Fallback sul nome completo se i parziali mancano
    final String fullName = payload['name'] ?? 'Utente Google';

    // 3. Controllo esistenza utente nel Database
    Map<String, dynamic>? userData = await _userRepository.findUserByEmail(email);

    UtenteGenerico user;
    String userType;

    // Determina il tipo in base alla lista dei domini
    final isSoccorritore = _isSoccorritore(email);
    userType = isSoccorritore ? 'Soccorritore' : 'users';
    if (userData != null) {
      // Caso A: L'utente esiste già
      userData.remove('passwordHash'); // Pulizia sicurezza

      if (isSoccorritore) {
        user = Soccorritore.fromJson(userData);
      } else {
        user = Utente.fromJson(userData);
      }
    } else {
      // Caso B: Primo accesso (Registrazione Automatica)
      final newUserMap = {
        'email': email,
        // Usa il first name, oppure spacca il full name, oppure usa l'intero nome come fallback
        'nome': firstName ?? fullName.split(' ').first,
        // Usa il last name, oppure prova a prendere l'ultima parte del full name
        'cognome': lastName ?? (fullName.contains(' ') ? fullName.split(' ').last : ''),
        'telefono': null,
        'passwordHash': '',
        'dataRegistrazione': DateTime.now().toIso8601String(),
        'isSoccorritore': isSoccorritore, // Salviamo il flag esplicitamente
      };

      // Salva nel DB tramite Repository
      final createdUserData = await _userRepository.createUser(
        newUserMap,
        collection: userType, // 'Soccorritore' o 'Utente'
      );

      if (isSoccorritore) {
        user = Soccorritore.fromJson(createdUserData);
      } else {
        user = Utente.fromJson(createdUserData);
      }
    }

    // 4. Generazione del Token JWT
    final token = _jwtService.generateToken(user.id!, userType);
    return {'user': user, 'token': token};
  }

  // Logica principale del Login (Email/Telefono + Password)
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

    // 2. Se l'email fallisce, tenta il login tramite TELEFONO
    if (userData == null && telefono != null) {
      userData = await _userRepository.findUserByPhone(telefono);
      if (userData != null) {
        finalEmail = (userData['email'] as String?) ?? '';
      }
    }

    // Utente non trovato
    if (userData == null) {
      return null;
    }

    final storedHash = (userData['passwordHash'] as String?) ?? '';
    if (storedHash.isEmpty) {
      throw Exception('Questo utente deve accedere tramite Google/Apple.');
    }

    // 3. Verifica della Password
    if (!_verifyPassword(password, storedHash)) {
      return null;
    }

    // 4. Determina il tipo di Utente e deserializza
    userData.remove('passwordHash');

    final UtenteGenerico user;
    final String userType;

    // Controllo domini multipli
    if (_isSoccorritore(finalEmail)) {
      user = Soccorritore.fromJson(userData);
      userType = 'Soccorritore';
    } else {
      user = Utente.fromJson(userData);
      userType = 'Utente';
    }

    // Genera il Token JWT
    final token = _jwtService.generateToken(user.id!, userType);
    return {'user': user, 'token': token};
  }

  // Login con Apple
  Future<Map<String, dynamic>?> loginWithApple({
    required String identityToken,
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    // 1. Verifica e Decodifica del Token Apple
    Map<String, dynamic> payload;
    try {
      payload = _decodeJWTPayload(identityToken);
    } catch (e) {
      throw Exception('Token Apple non valido o malformato.');
    }

    if (payload['iss'] != 'https://appleid.apple.com') {
      throw Exception('Issuer non valido');
    }

    final String tokenEmail = payload['email'] as String? ?? '';
    final String finalEmail = tokenEmail.isNotEmpty ? tokenEmail : (email ?? '');

    if (finalEmail.isEmpty) {
      throw Exception('Impossibile recuperare l\'email dall\'ID Apple.');
    }

    // 2. Controllo esistenza utente nel Database
    Map<String, dynamic>? userData = await _userRepository.findUserByEmail(finalEmail);

    UtenteGenerico user;

    // Controllo domini multipli
    final isSoccorritore = _isSoccorritore(finalEmail);
    final userType = isSoccorritore ? 'Soccorritore' : 'users';

    if (userData != null) {
      // CASO A: Utente già esistente
      userData.remove('passwordHash');
      if (isSoccorritore) {
        user = Soccorritore.fromJson(userData);
      } else {
        user = Utente.fromJson(userData);
      }
    } else {
      // CASO B: Primo accesso (Registrazione)
      // Qui firstName e lastName sono importanti perché Apple non li rimanda più.

      final newUserMap = {
        'email': finalEmail,
        'nome': firstName ?? 'Utente Apple', // Fallback se manca il nome
        'cognome': lastName ?? '',
        'telefono': null,
        'passwordHash': '',
        'fotoProfilo': null, // Apple non fornisce foto profilo
        'dataRegistrazione': DateTime.now().toIso8601String(),
        'authProvider': 'apple',
        'isSoccorritore': isSoccorritore,
      };

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

    // 3. Generazione Token Interno
    final token = _jwtService.generateToken(user.id!, userType);
    return {'user': user, 'token': token};
  }

  // Helper per decodificare il JWT
  Map<String, dynamic> _decodeJWTPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token JWT invalido');
    }
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(resp);
  }
}