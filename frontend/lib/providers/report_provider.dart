import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

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

  // Sottoscrizioni ai flussi di dati (fondamentali per il tempo reale)
  StreamSubscription? _reportsSubscription;
  StreamSubscription? _positionSubscription;

  // --- 1. AVVIO MONITORAGGIO (Sostituisce loadReports) ---
  // Da chiamare nell'initState di EmergencyNotification o HomeScreen
  void startRealtimeMonitoring() {
    // Evita di avviare più sottoscrizioni doppie
    if (_reportsSubscription != null) return;

    _isLoading = true;
    notifyListeners();

    // A. Ascolta la posizione GPS dell'utente (aggiorna ogni 10 metri)
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _currentPosition = position;
      _recalculateNearest(); // Ricalcola se l'utente si sposta
    });

    // B. Ascolta il Database Firestore (Active Emergencies)
    // Questo scatta automaticamente se QUALCUNO aggiunge un'emergenza nel DB
    _reportsSubscription = _repository.getReportsStream().listen((dynamicData) {
      // Conversione sicura per evitare l'errore "List<dynamic> is not subtype..."
      _emergencies = _parseEmergencies(dynamicData);

      // Appena i dati cambiano, ricalcoliamo chi è il più vicino
      _recalculateNearest();

      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print("Errore stream report: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  // --- 2. LOGICA DI CALCOLO ---
  // Trova l'emergenza più vicina basandosi su _currentPosition e _emergencies aggiornate
  void _recalculateNearest() {
    // Se mancano dati essenziali, resetta e esci
    if (_emergencies.isEmpty || _currentPosition == null) {
      _nearestEmergency = null;
      _distanceString = "";
      notifyListeners();
      return;
    }

    double minDistance = double.infinity;
    Map<String, dynamic>? nearest;

    for (var item in _emergencies) {
      // Parsing sicuro coordinate (gestisce sia int che double)
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

    // Aggiorna le variabili pubbliche
    _nearestEmergency = nearest;

    if (minDistance < 1000) {
      _distanceString = "A ${minDistance.toStringAsFixed(0)}m da te";
    } else {
      _distanceString = "A ${(minDistance / 1000).toStringAsFixed(1)}km da te";
    }

    // Notifica la UI per aggiornare il banner
    notifyListeners();
  }

  // --- 3. HELPER DI CONVERSIONE (Fix Type Error) ---
  List<Map<String, dynamic>> _parseEmergencies(List<dynamic> rawList) {
    return rawList.map((item) {
      // Cast esplicito da Object/Dynamic a Map
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  // --- 4. AZIONI UTENTE ---

  // Metodo legacy per compatibilità (se richiamato manualmente)
  Future<void> loadReports() async {
    startRealtimeMonitoring();
  }

  Future<bool> sendReport(String type, String description, double? lat, double? lng) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.createReport(type, description, lat, lng);
      // Non serve ricaricare: lo stream _reportsSubscription vedrà il nuovo dato e aggiornerà la UI
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Errore invio report: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resolveReport(String id) async {
    try {
      await _repository.closeReport(id);
      // Rimuoviamo localmente per feedback istantaneo,
      // ma il vero aggiornamento arriverà dallo stream poco dopo
      _emergencies.removeWhere((item) => item['id'] == id);
      _recalculateNearest();
      notifyListeners();
      return true;
    } catch (e) {
      print("Errore chiusura report: $e");
      return false;
    }
  }

  // Chiude le connessioni quando il provider viene distrutto (es. logout)
  @override
  void dispose() {
    _reportsSubscription?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}