import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'package:data_models/utente_generico.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';
import '../repositories/profile_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Per kIsWeb
import 'dart:io'; // Per Platform


// L'URL base viene costruito come in UserApiService, usando le costanti di default
// e sovrascrivendo per Android.
String get _baseUrl {
  String host = 'http://127.0.0.1';
  String portPart = ':8080';

  if (!kIsWeb && Platform.isAndroid && host.contains('127.0.0.1')) {
    // Sostituisce 'localhost' con l'IP speciale per l'emulatore
    host = 'http://10.0.2.2';
  } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS) && host.contains('127.0.0.1')) {
    // iOS / macOS usano localhost
    host = 'http://localhost';
  }

  return '$host$portPart/api'; // Aggiungiamo /api perché FCM lo userà per /api/profile/device/token
}

// Provider di Stato: AuthProvider
// Gestisce l'autenticazione, usa ChangeNotifier per notificare la UI
class AuthProvider extends ChangeNotifier {
  // Dipendenze: Repository per la comunicazione col Backend (API)
  final AuthRepository _authRepository = AuthRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  // Istanza per il Login Google (per signIn e signOut)
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String? _errorMessage;

  UtenteGenerico? _currentUser;
  String? _authToken;
  bool _isRescuer = false;

  // Variabili temporanee usate durante il processo di registrazione/verifica OTP
  String? _tempEmail;
  String? _tempPhone;
  String? _tempPassword;
  String? _tempNome;
  String? _tempCognome;

  int _secondsRemaining = 30;
  Timer? _timer;

  // Getters che espongono lo stato alla UI
  bool get isLoading => _isLoading;
  bool get isRescuer => _isRescuer;
  String? get errorMessage => _errorMessage;
  int get secondsRemaining => _secondsRemaining;
  UtenteGenerico? get currentUser => _currentUser;
  bool get isLogged => _authToken != null;

  // Tenta il login automatico se trova i dati di sessione salvati
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    // Controlla se esistono i token
    if (!prefs.containsKey('auth_token')) return;
    final token = prefs.getString('auth_token');
    final userDataString = prefs.getString('user_data');
    if (token != null && userDataString != null) {
      _authToken = token;
      try {
        final userMap = jsonDecode(userDataString);
        _currentUser = _parseUser(userMap);
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }

  // Metodo helper per salvare i dati di sessione (token + utente).
  Future<void> _saveSession(Map<String, dynamic> response) async {
    final token = response['token'];
    final userMap = response['user'];

    // Salva su SharedPreferences per la persistenza
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(userMap));

    // Aggiorna lo stato in memoria
    _authToken = token;
    _currentUser = _parseUser(userMap);

    // 🔔 CHIAMATA CRUCIALE: Avvia la gestione delle notifiche
    final userId = _currentUser?.id; // 💡 Rende l'ID un int?

    if (userId != null) {
      // 💡 Ora Dart sa che userId è int e non int? (risolvendo l'errore)
      _setupFCM(userId, token);
    }
  }

  // Metodo per convertire la Map JSON nell'oggetto Utente o Soccorritore
  UtenteGenerico _parseUser(Map<String, dynamic> json) {
    final isSoccorritore = (json['isSoccorritore'] == true);
    _isRescuer = isSoccorritore;

    if (isSoccorritore) {
      return Soccorritore.fromJson(json);
    } else {
      return Utente.fromJson(json);
    }
  }

  // Login con Email
  Future<String> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      // CASO 1: Login Successo
      if (response.containsKey('token')) {
        await _saveSession(response);
        _setLoading(false);
        return 'success';
      }
      // CASO 2: Utente Non Verificato
      else if (response['error'] == 'USER_NOT_VERIFIED') {
        // Dati temporanei per permettere l'invio/verifica OTP
        _tempEmail = email;
        _tempPassword = password;
        startTimer();
        await resendOtp();

        _setLoading(false);
        return 'verification_needed';
      }

      _setLoading(false);
      return 'failed';
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return 'failed';
    }
  }

  // Login con Telefono
  Future<String> loginPhone(String phone, String password) async {
    _setLoading(true);
    try {
      // Delega ad AuthRepository
      final response = await _authRepository.login(
        phone: phone,
        password: password,
      );

      // CASO 1: Login avvenuto con successo (il token è presente)
      if (response.containsKey('token')) {
        await _saveSession(response);
        _setLoading(false);
        return 'success';
      }
      // CASO 2: Utente corretto ma non verificato
      else if (response['error'] == 'USER_NOT_VERIFIED') {
        // Dati temporanei necessari per la verifica e il rinvio OTP
        _tempPhone = phone;
        _tempPassword = password;
        _tempEmail = null; // Residui di email
        startTimer();
        await resendOtp();

        _setLoading(false);
        return 'verification_needed';
      }

      // Caso fallback
      _setLoading(false);
      return 'failed';
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return 'failed';
    }
  }

  // Registrazione Email (Avvia l'invio OTP)
  Future<bool> register(
    String email,
    String password,
    String nome,
    String cognome,
  ) async {
    _setLoading(true);
    try {
      //Delega ad AuthRepository
      await _authRepository.register(email, password, nome, cognome);

      // Salva i dati temporanei per il reinvio/completamento verifica
      _tempEmail = email;
      _tempPhone = null;
      _tempPassword = password;
      _tempNome = nome;
      _tempCognome = cognome;

      startTimer();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // Registrazione Telefono (Avvia l'invio OTP)
  Future<bool> startPhoneAuth(
    String phoneNumber, {
    String? password,
    String? nome,
    String? cognome,
  }) async {
    _setLoading(true);
    try {
      //Delega ad AuthRepository
      await _authRepository.sendPhoneOtp(
        phoneNumber,
        password: password,
        nome: nome,
        cognome: cognome,
      );

      // Salva i dati temporanei per il reinvio/completamento verifica
      _tempPhone = phoneNumber;
      _tempEmail = null;
      _tempPassword = password;
      _tempNome = nome;
      _tempCognome = cognome;

      startTimer();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // Verifica OTP (Gestisce sia Email che Telefono)
  Future<bool> verifyCode(String code) async {
    // Validazione base dello stato di sessione
    if (_tempEmail == null && _tempPhone == null) {
      _errorMessage = "Errore sessione. Riprova la registrazione.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      //Delega ad AuthRepository
      final response = await _authRepository.verifyOtp(
        email: _tempEmail,
        phone: _tempPhone,
        code: code,
      );

      // Se la verifica è andata a buon fine, il backend restituisce il token di sessione
      if (response.containsKey('token')) {
        await _saveSession(response);
      }

      // Pulizia stato temporaneo
      stopTimer();
      _tempEmail = null;
      _tempPhone = null;
      _tempPassword = null;
      _tempNome = null;
      _tempCognome = null;

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // Resend OTP (Reinvia Codice)
  Future<void> resendOtp() async {
    _setLoading(true);
    try {
      // Logica per rinviare il codice basata sull'ultima modalità usata
      if (_tempEmail != null && _tempPassword != null) {
        // Usiamo dei placeholder per soddisfare la richiesta, tanto il backend
        // riconoscerà l'email esistente e aggiornerà solo l'OTP.
        final String nomeToSend = _tempNome ?? "Utente";
        final String cognomeToSend = _tempCognome ?? "Generico";

        // Delega ad AuthRepository
        await _authRepository.register(
          _tempEmail!,
          _tempPassword!,
          nomeToSend,
          cognomeToSend,
        );
        startTimer();
        _errorMessage = null;
      } else if (_tempPhone != null) {
        // Gestione fallback per Nome e Cognome (come per l'email)
        final String nomeToSend = _tempNome ?? "Utente";
        final String cognomeToSend = _tempCognome ?? "Generico";

        // Rinvia OTP Telefono con i dati completi
        await _authRepository.sendPhoneOtp(
          _tempPhone!,
          password: _tempPassword,
          nome: nomeToSend,
          cognome: cognomeToSend,
        );
        startTimer();
        _errorMessage = null;
      } else {
        throw Exception("Dati mancanti per rinviare codice.");
      }
    } catch (e) {
      _errorMessage = "Impossibile rinviare codice: ${_cleanError(e)}";
    } finally {
      _setLoading(false);
    }
  }

  // Logout Modificato
  Future<void> logout() async {
    // 1. Disconnessione da Google
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut(); // Disconnette l'account Google
      }
    } catch (e) {
      debugPrint('Errore: $e');
    }

    // 2. Pulizia sessione locale (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // 3. Reset stato interno
    _currentUser = null;
    _authToken = null;
    _isRescuer = false;

    notifyListeners();
  }

  // Gestione Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      // 1. Avvia il processo di autenticazione Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _setLoading(false);
        return false; // Utente ha annullato
      }

      // 2. Ottiene l'ID Token necessario per l'autenticazione lato server
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception("Impossibile recuperare ID Token Google");
      }

      // 3. Chiama il Backend inviando l'ID Token (Login/Registrazione Social)
      final response = await _authRepository.loginWithGoogle(idToken);

      // 4. Salva la sessione
      await _saveSession(response);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // Gestione Apple
  Future<bool> signInWithApple() async {
    _setLoading(true);
    try {
      // 1. Avvia il processo di autenticazione Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Chiama il Backend inviando i token e i dati anagrafici
      final response = await _authRepository.loginWithApple(
        identityToken: credential.identityToken!,
        email: credential.email,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );

      // 3. Salva sessione
      await _saveSession(response);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // Ricarica tutti i dati dell'utente dal server.
  Future<void> reloadUser() async {
    if (_currentUser?.id == null) return;

    try {
      // 1. Scarica il profilo aggiornato (delega a ProfileRepository)
      final UtenteGenerico? updatedUser = await _profileRepo.getUserProfile();

      if (updatedUser != null) {
        // 2. Aggiorna lo stato in memoria
        _currentUser = updatedUser;
        _isRescuer = updatedUser.isSoccorritore;

        final prefs = await SharedPreferences.getInstance();
        final currentToken = prefs.getString('auth_token');

        if (currentToken != null) {
          await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
        }

        // 3. Notifica la UI
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Errore ricaricamento profilo: $e");
    }
  }

  // Helper per aggiornare l'utente manualmente
  // Usato per aggiornare immediatamente la UI dopo un'azione
  void updateUserLocally({
    String? nome,
    String? cognome,
    String? telefono,
    String? citta,
  }) {
    if (_currentUser != null) {
      if (_currentUser is Utente) {
        final oldUser = _currentUser as Utente;
        _currentUser = oldUser.copyWith(
          nome: nome ?? oldUser.nome,
          cognome: cognome ?? oldUser.cognome,
          telefono: telefono ?? oldUser.telefono,
          cittaDiNascita: citta ?? oldUser.cittaDiNascita,
        );
      } else if (_currentUser is Soccorritore) {
        final oldUser = _currentUser as Soccorritore;
        _currentUser = oldUser.copyWith(
          nome: nome ?? oldUser.nome,
          cognome: cognome ?? oldUser.cognome,
          telefono: telefono ?? oldUser.telefono,
        );
        notifyListeners();
      }
    }
  }

  Future<void> _setupFCM(int userId, String authToken) async {
  final FirebaseMessaging fcm = FirebaseMessaging.instance;

  // 1. Richiesta Permessi
  NotificationSettings settings = await fcm.requestPermission();

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {

  // 2. Ottieni Token
  String? fcmToken = await fcm.getToken();
  if (fcmToken != null) {
  await _sendTokenToBackend(authToken, userId, fcmToken);
  }

  // 3. Configura i listener in foreground (Deve essere chiamato una volta per sessione)
  _configureFCMListeners();

  // 4. Gestisce il caso in cui il token cambi (raro, ma va gestito)
  fcm.onTokenRefresh.listen((newToken) {
  _sendTokenToBackend(authToken, userId, newToken);
  });

  } else {
  print('Permesso di notifica negato.');
  }
  }

  // 2. Invio Token all'Endpoint Protetta /api/profile/device/token
  Future<void> _sendTokenToBackend(
  String authToken, int userId, String fcmToken) async {
  try {
  // URL: http://...:8080/api/profile/device/token
  final url = Uri.parse('${_baseUrl}/profile/device/token');
  final response = await http.post(
  url,
  headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $authToken',
  },
  body: jsonEncode({'fcm_token': fcmToken}),
  );

  if (response.statusCode != 200) {
  debugPrint('Errore invio token al backend: ${response.statusCode} - ${response.body}');
  } else {
  debugPrint('Token FCM inviato con successo.');
  }
  } catch (e) {
  debugPrint('Errore HTTP/Rete durante invio token: $e');
  }
  }

  // 3. Configurazione dei Listener di Messaggio in Foreground
  // NOTA: Questa funzione non interagisce direttamente con EmergencyProvider QUI.
  // La gestione dello stato in foreground verrà fatta nel widget radice dell'app.
  void _configureFCMListeners() {
  // 🔔 App in Foreground (Aperta)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  final data = message.data;
  final type = data['type'];
  debugPrint("🔔 Messaggio in Foreground ricevuto: $type");

  // L'azione verrà gestita da un ProviderListener nel widget radice
  // per aggiornare correttamente l'UI/Stato dell'Emergenza.
  });

  // 👆 Tocco sulla Notifica (Gestito da codice esterno per la navigazione)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  debugPrint("👆 Notifica toccata: ${message.data['type']}. Navigazione gestita dall'esterno...");
  });
  }

  // Avvia il timer per l'OTP
  void startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        _secondsRemaining--;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  // Ferma il timer
  void stopTimer() {
    _timer?.cancel();
    _secondsRemaining = 0;
    notifyListeners();
  }

  // Controlla lo stato di caricamento e pulisce il messaggio di errore
  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  // Helper per pulire l'output di un errore
  String _cleanError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
