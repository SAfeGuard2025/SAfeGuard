import 'package:flutter/material.dart';
import 'package:data_models/Notifica.dart';
import '../repositories/profile_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();

  Notifica _notifiche = Notifica();
  bool _isLoading = false;
  String? _errorMessage;

  Notifica get notifiche => _notifiche;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carica le notifiche all'avvio
  Future<void> loadNotifiche() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifiche = await _profileRepository.fetchNotifiche();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiorna le notifiche (chiamato dagli switch)
  Future<void> updateNotifiche(Notifica nuoveNotifiche) async {
    // Aggiornamento ottimistico della UI
    _notifiche = nuoveNotifiche;
    notifyListeners();

    try {
      await _profileRepository.updateNotifiche(nuoveNotifiche);
    } catch (e) {
      _errorMessage = "Errore salvataggio: $e";
      // Rollback in caso di errore (ricarica i dati vecchi)
      await loadNotifiche();
    }
  }
}