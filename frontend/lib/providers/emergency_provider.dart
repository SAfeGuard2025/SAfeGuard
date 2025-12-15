import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/emergency_repository.dart';

// Provider di Stato: EmergencyProvider
// Gestisce lo stato e la persistenza delle emergenze basiche
// e il tracciamento della posizione in tempo reale
class EmergencyProvider extends ChangeNotifier {
  // Dipendenza: Repository per la comunicazione col Backend
  final EmergencyRepository _emergencyRepository = EmergencyRepository();

  bool _isSendingSos = false;
  String? _errorMessage;

  // Stream per mantenere aperta la connessione col GPS
  StreamSubscription<Position>? _positionStreamSubscription;

  bool get isSendingSos => _isSendingSos;
  String? get errorMessage => _errorMessage;

  // Invia un segnale SOS immediato
  Future<bool> sendInstantSos({
    required String? email,
    required String? phone,
    String type = "Generico",
    required String userId,
  }) async {
    debugPrint("[Provider] Inizio procedura SOS...");

    _isSendingSos = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Position position;

      Position? lastKnown = await Geolocator.getLastKnownPosition();

      if (lastKnown != null) {
        debugPrint(
          "[Provider] Trovata ultima posizione nota. Invio Immediato.",
        );
        position = lastKnown;
      } else {
        debugPrint(
          "[Provider] Nessuna posizione in memoria. Attendo fix preciso...",
        );
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }

      debugPrint(
        "[Provider] Posizione invio iniziale: ${position.latitude}, ${position.longitude}",
      );

      // 2. Delega ad EmergencyRepository per interagire con il DB (POST)
      await _emergencyRepository.sendSos(
        email: email,
        phone: phone,
        type: type,
        lat: position.latitude,
        lng: position.longitude,
      );

      debugPrint("[Provider] SOS inviato al server con successo!");

      // 3. Avvia il live tracking
      _startLiveTracking();

      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      debugPrint("[Provider] Errore invio SOS: $e");
      _errorMessage = _cleanError(e);
      _isSendingSos = false;
      notifyListeners();
      return false;
    }
  }

  // Interrompe l'SOS attivo
  Future<void> stopSos() async {
    try {
      // Ferma il tracking GPS
      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      // Delega a repository per fermare l emergenza
      await _emergencyRepository.stopSos();

      _isSendingSos = false;
      notifyListeners();
    } catch (e) {
      debugPrint("[Provider] Errore stop SOS: $e");
      _isSendingSos = false;
      _positionStreamSubscription?.cancel();
      notifyListeners();
    }
  }

  // Metodo per gestire il tracciamento continuo
  void _startLiveTracking() {
    _positionStreamSubscription?.cancel();

    // Aggiorna ogni 10 metri
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            debugPrint(
              "MOVIMENTO RILEVATO: ${position.latitude}, ${position.longitude}",
            );

            // Invia aggiornamento silenzioso al server
            _emergencyRepository.updateLocation(
              position.latitude,
              position.longitude,
            );
          },
        );
  }

  // Helper per pulire l'output di un errore
  String _cleanError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
