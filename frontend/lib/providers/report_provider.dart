import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/report_repository.dart';

// Provider di Stato: ReportProvider
// Apre uno stream con il DB per gestire lo stato della segnalazione più vicina
// in tempo reale e gestisce lo stato e la persistenza delle segnalazioni specifiche
class ReportProvider extends ChangeNotifier {
  final ReportRepository _reportRepository = ReportRepository();

  // Stato di caricamento per le azioni utente (es. invio report)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Dati locali
  List<Map<String, dynamic>> _emergencies = [];
  List<Map<String, dynamic>> get emergencies => _emergencies;

  // Variabili per il calcolo della vicinanza
  Map<String, dynamic>? _nearestEmergency;
  Map<String, dynamic>? get nearestEmergency => _nearestEmergency;

  String _distanceString = "";
  String get distanceString => _distanceString;

  // Posizione corrente dell'utente
  Position? _currentPosition;
  // Getter della posizione attuale dell'utente
  Position? get currentPosition => _currentPosition;

  // Sottoscrizioni ai flussi di dati (fondamentali per il tempo reale)
  StreamSubscription? _reportsSubscription;
  StreamSubscription? _positionSubscription;

  // Avvio Monitoraggio
  // Da chiamare nell'initState di EmergencyNotification o HomeScreen
  void startRealtimeMonitoring() {
    // Evita di avviare più sottoscrizioni doppie
    if (_reportsSubscription != null) return;

    _isLoading = true;
    notifyListeners();

    // 1. Ascolta la posizione GPS dell'utente (aggiorna ogni 10 metri)
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _currentPosition = position;
      _recalculateNearest(); // Ricalcola se l'utente si sposta
    });

    // 2. Ascolta il Database Firestore (Active Emergencies)
    // Questo scatta automaticamente se qualcuno aggiunge un'emergenza nel DB
    _reportsSubscription = _reportRepository.getReportsStream().listen((dynamicData) {
      _emergencies = _parseEmergencies(dynamicData);

      // Appena i dati cambiano, ricalcola l'emergenza più vicina
      _recalculateNearest();

      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print("Errore stream report: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  // 3. Logica di Calcolo
  // Trova l'emergenza più vicina basandosi su _currentPosition e _emergencies aggiornate
  void _recalculateNearest() {
    if (_emergencies.isEmpty || _currentPosition == null) {
      _nearestEmergency = null;
      _distanceString = "";
      notifyListeners();
      return;
    }

    double minDistance = double.infinity;
    Map<String, dynamic>? nearest;

    for (var item in _emergencies) {
      final double? eLat = (item['lat'] as num?)?.toDouble();
      final double? eLng = (item['lng'] as num?)?.toDouble();

      if (eLat != null && eLng != null) {
        // Calcola distanza in metri
        double distanceInMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          eLat,
          eLng,
        );

        if (distanceInMeters < minDistance) {
          minDistance = distanceInMeters;
          nearest = item;
        }
      }
    }

    //Aggiorna l'emergenza più vicina
    _nearestEmergency = nearest;

    if (minDistance < 1000) {
      _distanceString = "A ${minDistance.toStringAsFixed(0)}m da te";
    } else {
      _distanceString = "A ${(minDistance / 1000).toStringAsFixed(1)}km da te";
    }

    // Notifica la UI per aggiornare il banner
    notifyListeners();
  }

  // 4. Helper di Conversione
  List<Map<String, dynamic>> _parseEmergencies(List<dynamic> rawList) {
    return rawList.map((item) {
      // Cast esplicito da Object/Dynamic a Map
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  // Metodo legacy per compatibilità
  Future<void> loadReports() async {
    startRealtimeMonitoring();
  }

  // Invia una segnalazione delega a ReportRepository l'interazione con il backend
  Future<bool> sendReport(String type, String description, double? lat, double? lng) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportRepository.createReport(type, description, lat, lng);
      // Non serve ricaricare: lo stream _reportsSubscription vedrà il nuovo dato e aggiornerà la UI
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Errore invio report: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cancella una segnalazione delega a ReportRepository l'interazione con il backend
  Future<bool> resolveReport(String id) async {
    try {
      await _reportRepository.closeReport(id);
      // Rimuove la segnalazione localmente per feedback istantaneo,
      // ma il vero aggiornamento arriverà dallo stream inviato dal db
      _emergencies.removeWhere((item) => item['id'] == id);
      _recalculateNearest();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Errore chiusura report: $e");
      return false;
    }
  }

  // Chiude le connessioni quando il provider viene distrutto
  @override
  void dispose() {
    _reportsSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}