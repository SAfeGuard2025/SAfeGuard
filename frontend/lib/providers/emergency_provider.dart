import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// Importiamo il repository del frontend che comunica col backend
import '../repositories/emergency_repository.dart';

class EmergencyProvider extends ChangeNotifier {
  // Dipendenza: Repository per la comunicazione col Backend (API)
  final EmergencyRepository _repository = EmergencyRepository();

  bool _isSendingSos = false;
  String? _errorMessage;

  // Getters per la UI
  bool get isSendingSos => _isSendingSos;
  String? get errorMessage => _errorMessage;

  /// Invia un segnale SOS immediato.
  ///
  /// Raccoglie la posizione GPS e delega al Repository l'invio dei dati al Backend.
  /// Ritorna [true] se l'invio ha successo, [false] altrimenti.
  Future<bool> sendInstantSos({
    required String? email,
    required String? phone,
    String type = "Generico", required String userId
  }) async {
    print("🔥 [Provider] Inizio procedura SOS...");

    // Reset stato
    _isSendingSos = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Logica Frontend: Ottieni la posizione GPS attuale.
      // Questa parte DEVE stare nel frontend perché accede al sensore del telefono.
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      print("📍 [Provider] Posizione ottenuta: ${position.latitude}, ${position.longitude}");

      // 2. Logica Backend: Chiama il Repository per inviare i dati via API.
      // Non passiamo 'userId' perché il Backend lo ricaverà in modo sicuro dal Token JWT.
      await _repository.sendSos(
        email: email,
        phone: phone,
        type: type,
        lat: position.latitude,
        lng: position.longitude,
      );

      print("✅ [Provider] SOS inviato al server con successo!");

      // Ritardo estetico per UX (opzionale)
      await Future.delayed(const Duration(seconds: 1));

      // Non resettiamo _isSendingSos a false subito se vogliamo che la UI
      // mostri uno stato di "Allarme Attivo". Se invece la UI torna alla Home,
      // possiamo resettarlo. Per ora lo lasciamo true finché non viene stoppato.
      return true;

    } catch (e) {
      print("❌ [Provider] Errore invio SOS: $e");
      _errorMessage = _cleanError(e);
      _isSendingSos = false;
      notifyListeners();
      return false;
    }
  }

  /// Interrompe l'SOS attivo.
  Future<void> stopSos() async {
    try {
      // Chiama l'API di stop
      await _repository.stopSos();

      _isSendingSos = false;
      notifyListeners();
    } catch (e) {
      print("❌ [Provider] Errore stop SOS: $e");
      // Anche se fallisce la chiamata server, resettiamo lo stato locale
      // per non bloccare l'utente.
      _isSendingSos = false;
      notifyListeners();
    }
  }

  // Helper per pulire l'output di un errore (stile AuthProvider)
  String _cleanError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }
}