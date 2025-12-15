import 'dart:convert';
import 'dart:io';
// Per Platform.environment
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';
import 'package:data_models/utente_generico.dart';
import '../config/rescuer_config.dart';
import '../repositories/user_repository.dart';
import 'jwt_service.dart';

class LoginService {
  // Dipendenze: Repository per il DB e Service per la verifica
  //final UserRepository _userRepository = UserRepository();
  //final JWTService _jwtService = JWTService();

  //Modifica delle variabili per il testing
  final UserRepository _userRepository;
  final JWTService _jwtService;
  // Costruttore che permette di passare i mock
  LoginService({UserRepository? userRepository, JWTService? jwtService})
    : _userRepository = userRepository ?? UserRepository(),
      _jwtService = jwtService ?? JWTService();

  // Funzione privata per generare l'hash
  String _hashPassword(String password) {
    final secret = Platform.environment['HASH_SECRET'] ?? 'fallback_secret_dev';
    final bytes = utf8.encode(password + secret);
    return sha256.convert(bytes).toString();
  }

  // Confronta l'hash generato dalla password fornita con l'hash memorizzato
  bool _verifyPassword(String providedPassword, String storedHash) {
    final generatedHash = _hashPassword(providedPassword);
    return generatedHash == storedHash;
  }

  // Helper per verificare se un'email appartiene a un soccorritore
  bool _isSoccorritore(String email) {
    return RescuerConfig.isSoccorritore(email);
  }

  // Login con Google
  Future<Map<String, dynamic>?> loginWithGoogle(String googleIdToken) async {
    // 1. Verifica Remota del Token Google (API di Google)
    final verifyUrl = Uri.parse(
      'https://oauth2.googleapis.com/tokeninfo?id_token=$googleIdToken',
    );
    final response = await http.get(verifyUrl);

    if (response.statusCode != 200) {
      throw Exception('Token Google non valido o scaduto.');
    }

    // 2. Estrazione Dati utente dal Token
    final payload = jsonDecode(response.body);
    final String email = payload['email'];

    final String? firstName = payload['given_name'];
    final String? lastName = payload['family_name'];
    final String fullName = payload['name'] ?? 'Utente Google';

    // 3. Controllo esistenza utente nel Database
    Map<String, dynamic>? userData = await _userRepository.findUserByEmail(
      email,
    );

    UtenteGenerico user;
    String userType;

    // Determina il tipo in base alla lista dei domini
    final isSoccorritore = _isSoccorritore(email);
    userType = isSoccorritore ? 'Soccorritore' : 'users';

    if (userData != null) {
      // Caso A: L'utente esiste già (Login)
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
        // Fallback per nome/cognome se Google non li fornisce separati
        'nome': firstName ?? fullName.split(' ').first,
        'cognome':
            lastName ??
            (fullName.contains(' ') ? fullName.split(' ').last : ''),
        'telefono': null,
        'passwordHash': '',
        'dataRegistrazione': DateTime.now().toIso8601String(),
        'isSoccorritore': isSoccorritore, // Salviamo il flag esplicitamente
      };

      // Salva nel DB usando la collezione appropriata
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

    // 1. Tenta il login tramite email
    if (email != null) {
      userData = await _userRepository.findUserByEmail(email);
      if (userData != null) {
        finalEmail = email;
      }
    }

    // 2. Se l'email fallisce, tenta il login tramite telefono
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

    // Verifica la presenza dell'hash (gli utenti Google/Apple non hanno hash)
    final storedHash = (userData['passwordHash'] as String?) ?? '';
    if (storedHash.isEmpty) {
      throw Exception('Questo utente deve accedere tramite Google/Apple.');
    }

    // 3. Verifica della Password
    if (!_verifyPassword(password, storedHash)) {
      return null;
    }

    // Verifica dello stato Attivo/Verificato
    // Se l'utente ha la password corretta ma non ha verificato l'account
    final bool isVerified =
        (userData['isVerified'] == true) || (userData['attivo'] == true);
    if (!isVerified) {
      // Lanciamo un'eccezione specifica che il Controller catturerà
      throw Exception('USER_NOT_VERIFIED');
    }

    // 4. Determina il tipo di utente e deserializza
    userData.remove('passwordHash');

    final UtenteGenerico user;
    final String userType;

    if (_isSoccorritore(finalEmail)) {
      user = Soccorritore.fromJson(userData);
      userType = 'Soccorritore';
    } else {
      user = Utente.fromJson(userData);
      userType = 'Utente';
    }

    // 5. Genera il Token JWT per la sessione
    final token = _jwtService.generateToken(user.id!, userType);
    return {'user': user, 'token': token};
  }

  // Login con Apple
  Future<Map<String, dynamic>?> loginWithApple({
    required String identityToken,
    String? email, // Email fornita dal client (disponibile solo al primo login)
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

    // Validazione dell'emittente (issuer)
    if (payload['iss'] != 'https://appleid.apple.com') {
      throw Exception('Issuer non valido');
    }

    // Prende l'email dal token o dal body della richiesta
    final String tokenEmail = (payload['email'] as String? ?? '').toLowerCase();
    final String finalEmail = tokenEmail.isNotEmpty
        ? tokenEmail
        : (email?.toLowerCase() ?? '');

    if (finalEmail.isEmpty) {
      throw Exception('Impossibile recuperare l\'email dall\'ID Apple.');
    }

    // 2. Controllo esistenza utente nel Database
    Map<String, dynamic>? userData = await _userRepository.findUserByEmail(
      finalEmail,
    );

    UtenteGenerico user;
    final isSoccorritore = _isSoccorritore(finalEmail);
    final userType = isSoccorritore ? 'Soccorritore' : 'users';

    if (userData != null) {
      // Caso A: Utente già esistente (Login)
      userData.remove('passwordHash');
      user = isSoccorritore
          ? Soccorritore.fromJson(userData)
          : Utente.fromJson(userData);
    } else {
      // Caso B: Primo accesso (Registrazione Automatica)
      final newUserMap = {
        'email': finalEmail,
        'nome': firstName ?? 'Utente Apple', // Fallback se manca il nome
        'cognome': lastName ?? '',
        'telefono': null,
        'passwordHash': '',
        'fotoProfilo': null,
        'dataRegistrazione': DateTime.now().toIso8601String(),
        'authProvider': 'apple',
        'isSoccorritore': isSoccorritore,
      };

      final createdUserData = await _userRepository.createUser(
        newUserMap,
        collection: userType,
      );

      user = isSoccorritore
          ? Soccorritore.fromJson(createdUserData)
          : Utente.fromJson(createdUserData);
    }

    // 3. Generazione Token Interno
    final token = _jwtService.generateToken(user.id!, userType);
    return {'user': user, 'token': token};
  }

  // Helper per decodificare il Payload di un JWT
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
