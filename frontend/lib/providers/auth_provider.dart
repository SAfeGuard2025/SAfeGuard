import 'package:flutter/material.dart';
import 'dart:async';
import 'package:frontend/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  // Serve per ricordare l'email durante il flusso di verifica OTP
  String? _tempEmail;
  // Serve per ricordare la password nel caso dovessimo rifare la registrazione (opzionale)
  String? _tempPassword;

  // --- STATO DEL TIMER ---
  int _secondsRemaining = 30;
  Timer? _timer;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get secondsRemaining => _secondsRemaining;

  // ----------------------------------------------------------------
  // LOGICA REALE CON IL SERVER
  // ----------------------------------------------------------------

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      // Chiama /api/auth/login
      // Nota: AuthRepository.login restituisce void o lancia eccezione se fallisce
      await _authRepository.login(email, password);

      // TODO: Quando il backend restituirà un token JWT, dovrai modificare
      // il repository per restituirlo e salvarlo qui nelle SharedPreferences.

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    try {
      // Chiama /api/auth/register
      // Se fallisce, lancia un'eccezione che viene catturata dal catch
      await _authRepository.register(email, password);

      // Salviamo le credenziali temporaneamente
      _tempEmail = email;
      _tempPassword = password;

      // Avviamo il timer per l'inserimento del codice
      startTimer();

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _setLoading(false);
      return false;
    }
  }

  // Verifica il codice inserito dall'utente chiamando il server
  Future<bool> verifyCode(String code) async {
    if (_tempEmail == null) {
      _errorMessage = "Email non trovata. Riprova la registrazione.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      // Chiama /api/verify usando l'email salvata e il codice inserito
      bool isValid = await _authRepository.verifyOtp(_tempEmail!, code);

      _setLoading(false);

      if (isValid) {
        stopTimer();
        // Pulizia dati temporanei dopo successo
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

  /// Metodo per rinviare il codice
  Future<void> resendOtp() async {
    if (_tempEmail == null || _tempPassword == null) {
      _errorMessage = "Dati scaduti. Registrati di nuovo.";
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

  // --- GESTIONE TIMER ---
  void startTimer() {
    _secondsRemaining = 30; // Reset a 30 secondi
    _timer?.cancel(); // Cancella eventuali timer vecchi

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel(); // Ferma quando arriva a 0
      } else {
        _secondsRemaining--; // Scala 1 secondo
        notifyListeners(); // Avvisa la UI di aggiornare il testo
      }
    });
    notifyListeners(); // Aggiornamento iniziale
  }

  void stopTimer() {
    _timer?.cancel();
    _secondsRemaining = 0;
    notifyListeners(); // Importante notificare per aggiornare la UI
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null; // Resetta errori vecchi
    notifyListeners();
  }

  // Helper per pulire i messaggi di errore
  String _cleanError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
