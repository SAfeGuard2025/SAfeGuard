import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// Importiamo il repository del frontend che comunica col backend
import '../repositories/emergency_repository.dart';

// Classe per modellare i dati di emergenza ricevuti da FCM
class EmergencyAlert {
  final String sosId;
  final String type;
  final String category;
  final double lat;
  final double lng;

  EmergencyAlert.fromJson(Map<String, dynamic> data)
      : sosId = data['sosId'] as String? ?? '',
        type = data['type'] as String? ?? '',
        category = data['category'] as String? ?? '',
        lat = double.tryParse(data['lat']?.toString() ?? '') ?? 0.0,
        lng = double.tryParse(data['lng']?.toString() ?? '') ?? 0.0;

  // Converte l'oggetto in Map per passarlo ai gestori
  Map<String, dynamic> toJson() => {
    'sosId': sosId,
    'type': type,
    'category': category,
    'lat': lat.toString(),
    'lng': lng.toString(),
  };
}

class EmergencyProvider extends ChangeNotifier {
  // Dipendenza: Repository per la comunicazione col Backend (API)
  final EmergencyRepository _repository = EmergencyRepository();

  bool _isSendingSos = false;
  String? _errorMessage;
  EmergencyAlert? _currentAlert;

  // Stream per mantenere aperta la connessione col GPS
  StreamSubscription<Position>? _positionStreamSubscription;

  bool get isSendingSos => _isSendingSos;
  String? get errorMessage => _errorMessage;
  EmergencyAlert? get currentAlert => _currentAlert;

  // Invia un segnale SOS immediato (LOGICA IBRIDA VELOCE)
  Future<bool> sendInstantSos({
    required String? email,
    required String? phone,
    String type = "Generico",
    required String userId
  }) async {
    // Uso debugPrint per evitare warning in produzione
    debugPrint("🔥 [Provider] Inizio procedura SOS...");

    _isSendingSos = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Position position;

      // Strategia GPS ibrida
      Position? lastKnown = await Geolocator.getLastKnownPosition();

      if (lastKnown != null) {
        debugPrint("🚀 [Provider] Trovata ultima posizione nota. Invio Immediato.");
        position = lastKnown;
      } else {
        debugPrint("⏳ [Provider] Nessuna posizione in memoria. Attendo fix preciso...");
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }

      debugPrint("📍 [Provider] Posizione invio iniziale: ${position.latitude}, ${position.longitude}");

      // 2. Chiamata al Backend (POST)
      await _repository.sendSos(
        email: email,
        phone: phone,
        type: type,
        lat: position.latitude,
        lng: position.longitude,
      );

      debugPrint("✅ [Provider] SOS inviato al server con successo!");

      // 3. Avvia il live tracking
      _startLiveTracking();

      // Ritardo estetico minimo
      await Future.delayed(const Duration(milliseconds: 500));

      return true;

    } catch (e) {
      debugPrint("❌ [Provider] Errore invio SOS: $e");
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

      // Chiama l'API di stop
      await _repository.stopSos();

      _isSendingSos = false;
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [Provider] Errore stop SOS: $e");
      _isSendingSos = false;
      _positionStreamSubscription?.cancel();
      notifyListeners();
    }
  }

  // Metodo per gestire il tracciamento continuo (Live Tracking)
  void _startLiveTracking() {
    _positionStreamSubscription?.cancel();

    // Aggiorna ogni 10 metri
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings
    ).listen((Position position) {
      debugPrint("📍 MOVIMENTO RILEVATO: ${position.latitude}, ${position.longitude}");

      // Invia aggiornamento silenzioso al server (PATCH)
      _repository.updateLocation(position.latitude, position.longitude);
    });
  }

  void handleNewAlert(Map<String, dynamic> data) {
    debugPrint('EmergencyProvider: Allerta in Foreground ricevuta: ${data['type']}');
    _currentAlert = EmergencyAlert.fromJson(data);
    notifyListeners();
  }
  // Gestisce il tocco sulla notifica o il messaggio iniziale (per la navigazione).
  void handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('EmergencyProvider: Notifica toccata/Iniziale. Tipo: ${data['type']}');
    _currentAlert = EmergencyAlert.fromJson(data);
    notifyListeners();
  }


  // Helper per pulire l'output di un errore (stile AuthProvider)
  String _cleanError(Object e) {
    return e.toString().replaceAll("Exception: ", "");
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}