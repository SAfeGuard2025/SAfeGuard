import 'package:flutter/material.dart';
import 'package:data_models/notifica.dart';
import '../repositories/profile_repository.dart';

// Provider di Stato: NotificationProvider
// Gestisce lo stato e la persistenza delle preferenze di notifica dell'utente.
class NotificationProvider extends ChangeNotifier {
  // Dipendenza: Repository per la comunicazione con il Backend/Database
  final ProfileRepository _profileRepository = ProfileRepository();

  Notifica _notifiche = Notifica();
  bool _isLoading = false;
  String? _errorMessage;

  Notifica get notifiche => _notifiche;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carica le preferenze di notifica all'avvio della schermata
  Future<void> loadNotifiche() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Delega a ProfileRepository la fetch delle notifiche
      _notifiche = await _profileRepository.fetchNotifiche();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiorna le preferenze di notifiche
  Future<void> updateNotifiche(Notifica nuoveNotifiche) async {
    _notifiche = nuoveNotifiche;
    notifyListeners();

    try {
      await _profileRepository.updateNotifiche(nuoveNotifiche);
    } catch (e) {
      _errorMessage = "Errore salvataggio: $e";
      // Rollback in caso di errore
      await loadNotifiche();
    }
  }
}
