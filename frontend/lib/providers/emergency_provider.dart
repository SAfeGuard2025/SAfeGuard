import 'package:flutter/material.dart';

// Provider di Stato: EmergencyProvider
// Gestisce lo stato e la logica relativi all'attivazione delle emergenze
class EmergencyProvider extends ChangeNotifier {
  bool _isSendingSos = false;

  bool get isSendingSos => _isSendingSos;

  Future<void> sendSos() async {
    _isSendingSos = true;
    notifyListeners();

    // Simulazione chiamata SOS
    await Future.delayed(const Duration(seconds: 3));

    _isSendingSos = false;
    notifyListeners();
  }
}
