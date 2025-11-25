import 'dart:convert';
import 'dart:io'; // Per Platform.environment
import 'package:crypto/crypto.dart'; // Importa crypto
import 'package:http/http.dart' as http;

import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import '../repositories/UserRepository.dart';
import 'JWTService.dart';

// Dominio speciale per i soccorritori da modificare poi
const String rescuerDomain = '@soccorritore.com';

class LoginService {
  final UserRepository _userRepository = UserRepository();
  final JWTService _jwtService = JWTService();

  // Funzione privata per generare l'hash (Deve essere IDENTICA a quella del RegisterService)
  String _hashPassword(String password) {
    final secret = Platform.environment['HASH_SECRET'] ?? 'fallback_secret_dev';
    final bytes = utf8.encode(password + secret);
    return sha256.convert(bytes).toString();
  }

  bool _verifyPassword(String providedPassword, String storedHash) {
    // Calcoliamo l'hash della password appena inserita
    final generatedHash = _hashPassword(providedPassword);

    // Confrontiamo l'hash calcolato con quello nel DB
    return generatedHash == storedHash;
  }

  // Login con Google
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
      // Caso A: L'utente esiste già
      userData.remove('passwordHash'); // Pulizia sicurezza

      if (isSoccorritore) {
        user = Soccorritore.fromJson(userData);
      } else {
        user = Utente.fromJson(userData);
      }
    } else {
      // Caso B: Primo accesso (Registrazione Automatica)
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

    // Utente non trovato in nessuno dei due modi
    if (userData == null) {
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

  // Login con Apple
  Future<Map<String, dynamic>?> loginWithApple({
    required String identityToken,
    String? email, // Apple lo manda nel body della richiesta la prima volta
    String? firstName, // Apple lo manda nel body la prima volta
    String? lastName, // Apple lo manda nel body la prima volta
  }) async {
    // 1. Verifica e Decodifica del Token Apple
    // In un ambiente reale, bisogna verificare la firma crittografica del token
    // usando le chiavi pubbliche di Apple (JWKS).
    // Per questa implementazione, decodifichiamo il payload senza verifica firma.
    Map<String, dynamic> payload;
    try {
      payload = _decodeJWTPayload(identityToken);
    } catch (e) {
      throw Exception('Token Apple non valido o malformato.');
    }

    // Verifica issuer e audience
    if (payload['iss'] != 'https://appleid.apple.com') {
      throw Exception('Issuer non valido');
    }

    // L'email è contenuta nel token, ma a volte il frontend la passa esplicitamente
    // se l'utente ha scelto di nasconderla e Apple la manda nel token come relay.
    final String tokenEmail = payload['email'] as String? ?? '';

    // Usiamo l'email del token se presente, altrimenti quella passata dal frontend
    final String finalEmail = tokenEmail.isNotEmpty
        ? tokenEmail
        : (email ?? '');

    if (finalEmail.isEmpty) {
      throw Exception('Impossibile recuperare l\'email dall\'ID Apple.');
    }

    // 2. Controllo esistenza utente nel Database
    Map<String, dynamic>? userData = await _userRepository.findUserByEmail(
      finalEmail,
    );

    UtenteGenerico user;
    final isSoccorritore = finalEmail.toLowerCase().endsWith(
      rescuerDomain,
    ); // Logica dominio
    final userType = isSoccorritore ? 'Soccorritore' : 'Utente';

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
        'authProvider': 'apple', // Utile per sapere da dove arriva
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

  // Helper per decodificare il JWT (Solo parte Payload, senza verifica firma)
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
