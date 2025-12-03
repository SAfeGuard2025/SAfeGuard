import 'package:flutter/material.dart';
import '../repositories/report_repository.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository = ReportRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Invia la segnalazione e gestisce lo stato di caricamento
  Future<bool> sendReport(String type, String description) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.createReport(type, description);
      _isLoading = false;
      notifyListeners();
      return true; // Successo
    } catch (e) {
      print("Errore invio report: $e");
      _isLoading = false;
      notifyListeners();
      return false; // Errore
    }
  }
}