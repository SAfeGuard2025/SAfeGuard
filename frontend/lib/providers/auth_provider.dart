import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:frontend/repositories/auth_repository.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';

import '../repositories/profile_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  UtenteGenerico? _currentUser;
  String? _authToken;
  bool _isRescuer = false;

  String? _tempEmail;
  String? _tempPhone; // Variabile per il numero di telefono
  String? _tempPassword;

  String? _tempNome;
  String? _tempCognome;

  int _secondsRemaining = 30;
  Timer? _timer;

  bool get isLoading => _isLoading;
  bool get isRescuer => _isRescuer; // se è soccorritore è true se no è false
  String? get errorMessage => _errorMessage;
  int get secondsRemaining => _secondsRemaining;
  UtenteGenerico? get currentUser => _currentUser;
  bool get isLogged => _authToken != null;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
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

// --- MODIFICA: LOGIN EMAIL ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _authRepository.login(email: email, password: password);
      await _saveSession(response);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginPhone(String phone, String password) async {
    _setLoading(true);
    try {
      final response = await _authRepository.login(phone: phone, password: password);
      await _saveSession(response);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // --- REGISTRAZIONE EMAIL ---
  Future<bool> register(String email, String password, String nome, String cognome) async {
    _setLoading(true);
    try {
      await _authRepository.register(email, password, nome, cognome);

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

  // --- REGISTRAZIONE TELEFONO ---
  Future<bool> startPhoneAuth(String phoneNumber, {String? password, String? nome, String? cognome}) async {
    _setLoading(true);
    try {
      await _authRepository.sendPhoneOtp(phoneNumber, password: password, nome: nome, cognome: cognome);

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

  // --- VERIFICA OTP (Gestisce sia Email che Telefono) ---
  Future<bool> verifyCode(String code) async {
    if (_tempEmail == null && _tempPhone == null) {
      _errorMessage = "Errore sessione. Riprova la registrazione.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      final response = await _authRepository.verifyOtp(
        email: _tempEmail,
        phone: _tempPhone,
        code: code,
      );

      if (response.containsKey('token')) {
        await _saveSession(response);
      }

      stopTimer();
      _tempEmail = null; _tempPhone = null; _tempPassword = null;
      _tempNome = null; _tempCognome = null;

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // --- RESEND OTP (RINVIA CODICE) ---
  Future<void> resendOtp() async {
    _setLoading(true);
    try {
      if (_tempEmail != null && _tempPassword != null && _tempNome != null && _tempCognome != null) {
        await _authRepository.register(_tempEmail!, _tempPassword!, _tempNome!, _tempCognome!);
        startTimer();
        _errorMessage = null;
      } else if (_tempPhone != null) {
        // Se ho tutti i dati, uso sendPhoneOtp con password e anagrafica
        await _authRepository.sendPhoneOtp(
            _tempPhone!,
            password: _tempPassword,
            nome: _tempNome,
            cognome: _tempCognome
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _authToken = null;
    _isRescuer = false;
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> response) async {
    final token = response['token'];
    final userMap = response['user'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(userMap));
    _authToken = token;
    _currentUser = _parseUser(userMap);
  }

  UtenteGenerico _parseUser(Map<String, dynamic> json) {
    final isSoccorritore = (json['isSoccorritore'] == true);
    _isRescuer = isSoccorritore;

    if (isSoccorritore) {
      return Soccorritore.fromJson(json);
    } else {
      return Utente.fromJson(json);
    }
  }

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

  void stopTimer() {
    _timer?.cancel();
    _secondsRemaining = 0;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  String _cleanError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Aggiungi un'istanza del ProfileRepository se non vuoi ricrearla ogni volta,
  // oppure usala localmente nel metodo.
  final ProfileRepository _profileRepo = ProfileRepository();

// --- RICARICAMENTO DATI DAL SERVER ---
  Future<void> reloadUser() async {
    // Se non siamo loggati, inutile ricaricare
    if (_currentUser?.id == null) return;

    try {
      // 1. Scarica il profilo aggiornato
      final UtenteGenerico? updatedUser = await _profileRepo.getUserProfile();

      if (updatedUser != null) {
        // 2. Aggiorna la variabile in memoria
        _currentUser = updatedUser;

        // 3. Aggiorna lo stato "isRescuer" (per sicurezza)
        _isRescuer = updatedUser.isSoccorritore;

        // 4. Aggiorna le SharedPreferences (Sessione persistente)
        // Dobbiamo recuperare il token attuale perché getUserProfile non lo restituisce
        final prefs = await SharedPreferences.getInstance();
        final currentToken = prefs.getString('auth_token');

        if (currentToken != null) {
          await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
        }

        // 5. Notifica la UI
        notifyListeners();
      }
    } catch (e) {
      print("Errore ricaricamento profilo: $e");
      // Non blocchiamo l'app, stampiamo solo l'errore
    }
  }

//Helper per aggiornare l'utente manualmente (Optimistic Update)
  void updateUserLocally({String? nome, String? cognome, String? telefono, String? citta}) {
    if (_currentUser != null) {

      // Se è un CITTADINO (Utente)
      if (_currentUser is Utente) {
        final oldUser = _currentUser as Utente;

        // Usiamo il copyWith che esiste in Utente
        _currentUser = oldUser.copyWith(
          nome: nome ?? oldUser.nome,
          cognome: cognome ?? oldUser.cognome,
          telefono: telefono ?? oldUser.telefono,
          cittaDiNascita: citta ?? oldUser.cittaDiNascita,
        );
      }
      // Se è un SOCCORRITORE (Soccorritore non ha copyWith nel codice fornito, lo gestiamo manualmente o ricarichiamo)
      else if (_currentUser is Soccorritore) {
        // Poiché Soccorritore nel codice fornito non ha un copyWith esplicito comodo come Utente,
        // e i campi di UtenteGenerico sono final, la cosa più semplice è aspettare il reloadUser.
        // Tuttavia, se vuoi forzarlo, dovresti ricreare l'oggetto Soccorritore.
        // Per ora lasciamo che reloadUser gestisca la verità dei dati per il soccorritore.
      }

      notifyListeners();
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // --- GESTIONE GOOGLE ---
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    try {
      // 1. Apre il popup nativo di Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return false; // Utente ha annullato
      }

      // 2. Ottiene i token (idToken e accessToken)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception("Impossibile recuperare ID Token Google");

      // 3. Chiama il Backend
      final response = await _authRepository.loginWithGoogle(idToken);

      // 4. Salva la sessione (usa il tuo metodo esistente _saveSession)
      await _saveSession(response);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // --- GESTIONE APPLE ---
  Future<bool> signInWithApple() async {
    _setLoading(true);
    try {
      // 1. Apre il popup nativo Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Chiama il Backend
      // Nota: email e nomi sono presenti solo al PRIMO login su Apple, poi sono null.
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
}