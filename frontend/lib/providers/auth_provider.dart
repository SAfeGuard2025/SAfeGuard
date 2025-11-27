import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/repositories/auth_repository.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  // Dati utente loggato
  UtenteGenerico? _currentUser;
  String? _authToken;
  bool _isRescuer = false;

  // Dati temporanei per OTP
  String? _tempEmail;
  String? _tempPassword;
  int _secondsRemaining = 30;
  Timer? _timer;

  // Getters
  bool get isLoading => _isLoading;
  bool get isRescuer => _isRescuer;
  String? get errorMessage => _errorMessage;
  int get secondsRemaining => _secondsRemaining;
  UtenteGenerico? get currentUser => _currentUser;

  // Getter fondamentale per la UI
  bool get isLogged => _authToken != null;

  // --- AUTO LOGIN (Al lancio dell'app) ---
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

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _authRepository.login(email, password);

      final token = response['token'];
      final userMap = response['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_data', jsonEncode(userMap));

      _authToken = token;
      _currentUser = _parseUser(userMap);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // --- REGISTRAZIONE ---
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.register(email, password);

      _tempEmail = email;
      _tempPassword = password;
      startTimer();

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // --- VERIFICA OTP ---
  Future<bool> verifyCode(String code) async {
    if (_tempEmail == null) {
      _errorMessage = "Errore: Email persa.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      bool isValid = await _authRepository.verifyOtp(_tempEmail!, code);
      _setLoading(false);

      if (isValid) {
        stopTimer();
        _tempEmail = null;
        _tempPassword = null;
        return true;
      } else {
        _errorMessage = "Codice non valido.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // --- RESEND OTP (RINVIA CODICE) ---
  Future<void> resendOtp() async {
    if (_tempEmail == null || _tempPassword == null) {
      _errorMessage = "Dati sessione scaduti. Registrati di nuovo.";
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      // Nota: Poiché il tuo server non ha un endpoint specifico "resend",
      // richiamiamo la registrazione. Il backend deve essere in grado di gestire
      // un "aggiornamento" OTP se l'utente esiste ma non è verificato.
      // Altrimenti, dovresti creare una rotta specifica server-side /api/resend-otp
      await _authRepository.register(_tempEmail!, _tempPassword!);

      startTimer(); // Riavvia il timer
      _errorMessage = null; // Pulisce eventuali errori precedenti
    } catch (e) {
      _errorMessage = "Impossibile rinviare codice: ${_cleanError(e)}";
    } finally {
      _setLoading(false);
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _authToken = null;
    notifyListeners();
  }

  // --- UTILS ---
  UtenteGenerico _parseUser(Map<String, dynamic> json) {
    if (json['isSoccorritore'] == true) {
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
}