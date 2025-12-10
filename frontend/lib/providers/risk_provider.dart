import 'package:flutter/material.dart';
import 'package:data_models/risk_hotspot.dart';
import '../repositories/risk_repository.dart';

class RiskProvider extends ChangeNotifier {
  final RiskRepository _riskRepository = RiskRepository();
  List<RiskHotspot> _hotspots = [];
  bool _isLoading = false;

  //Variabile di stato per la visibilità
  bool _showHotspots = true;

  List<RiskHotspot> get hotspots => _hotspots;
  bool get isLoading => _isLoading;
  bool get showHotspots => _showHotspots;

  // Carica i dati all'avvio o su richiesta
  Future<void> loadHotspots() async {
    _isLoading = true;
    notifyListeners();
    try {
      _hotspots = await _riskRepository.getRiskHotspots();
    } catch (e) {
      debugPrint("Errore provider risk: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Metodo per cambiare la visibilità
  void toggleHotspotVisibility(bool value) {
    _showHotspots = value;
    notifyListeners();
  }
}
