import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../repositories/report_repository.dart';

// Provider di Stato: ReportProvider
class ReportProvider extends ChangeNotifier {
  final ReportRepository _reportRepository = ReportRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _emergencies = [];
  List<Map<String, dynamic>> get emergencies => _emergencies;

  Map<String, dynamic>? _nearestEmergency;
  Map<String, dynamic>? get nearestEmergency => _nearestEmergency;

  String _distanceString = "";
  String get distanceString => _distanceString;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  StreamSubscription? _reportsSubscription;
  StreamSubscription? _positionSubscription;

  // Stream specifico per il tracking "SAFE"
  StreamSubscription? _safeTrackingSubscription;

  void startRealtimeMonitoring() {
    if (_reportsSubscription != null) return;

    _isLoading = true;
    notifyListeners();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _currentPosition = position;
            _recalculateNearest(); // Ricalcola se l'utente si sposta
          },
        );

    _reportsSubscription = _reportRepository.getReportsStream().listen(
      (dynamicData) {
        _emergencies = _parseEmergencies(dynamicData);
        _recalculateNearest();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Errore stream report: $e");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

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
      // Ignora i report "SAFE" per il banner delle emergenze vicine
      if (item['type'] == 'SAFE') continue;

      final double? eLat = (item['lat'] as num?)?.toDouble();
      final double? eLng = (item['lng'] as num?)?.toDouble();

      if (eLat != null && eLng != null) {
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

    _nearestEmergency = nearest;

    if (minDistance < 1000) {
      _distanceString = "A ${minDistance.toStringAsFixed(0)}m da te";
    } else {
      _distanceString = "A ${(minDistance / 1000).toStringAsFixed(1)}km da te";
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> _parseEmergencies(List<dynamic> rawList) {
    return rawList.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  Future<void> loadReports() async {
    startRealtimeMonitoring();
  }

  Future<bool> sendReport(
    String type,
    String description,
    double? lat,
    double? lng, {
    required int severity,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportRepository.createReport(
        type,
        description,
        lat,
        lng,
        severity,
      );
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

  //FUNZIONE PER "STO BENE" CON TRACKING
  Future<bool> sendSafeStatusWithTracking() async {
    try {
      Position startPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String reportId = await _reportRepository.createReportAndGetId(
        "SAFE",
        "L'utente ha confermato di stare bene.",
        startPos.latitude,
        startPos.longitude,
        0,
      );

      const trackSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );

      _safeTrackingSubscription?.cancel();

      _safeTrackingSubscription =
          Geolocator.getPositionStream(locationSettings: trackSettings).listen((
            Position pos,
          ) {
            _reportRepository.updateReportLocation(
              reportId,
              pos.latitude,
              pos.longitude,
            );
          });

      // Ferma il tracking dopo 30 secondi
      Timer(const Duration(seconds: 30), () {
        _safeTrackingSubscription?.cancel();
        _safeTrackingSubscription = null;
      });

      return true;
    } catch (e) {
      debugPrint("Errore safe tracking: $e");
      return false;
    }
  }

  Future<bool> resolveReport(String id) async {
    try {
      await _reportRepository.closeReport(id);
      _emergencies.removeWhere((item) => item['id'] == id);
      _recalculateNearest();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Errore chiusura report: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    _positionSubscription?.cancel();
    _safeTrackingSubscription?.cancel();
    super.dispose();
  }
}
