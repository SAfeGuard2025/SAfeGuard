import 'package:flutter/material.dart';
import 'package:data_models/permesso.dart';
import '../repositories/profile_repository.dart';

// Provider di Stato: PermissionProvider
// Gestisce lo stato e la persistenza dei permessi OS dell'utente nel database.
class PermissionProvider extends ChangeNotifier {
  // Dipendenza: Repository per la comunicazione con il Backend/Database
  final ProfileRepository _profileRepository = ProfileRepository();

  Permesso _permessi = Permesso(); // Stato iniziale (tutto false)
  bool _isLoading = false;
  String? _errorMessage;

  Permesso get permessi => _permessi;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carica i permessi all'avvio
  Future<void> loadPermessi() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Delega a ProfileRepository la fetch dei permessi
      _permessi = await _profileRepository.fetchPermessi();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiorna lo stato dei permessi
  Future<void> updatePermessi(Permesso nuoviPermessi) async {
    _permessi = nuoviPermessi;
    notifyListeners();

    try {
      await _profileRepository.updatePermessi(nuoviPermessi);
    } catch (e) {
      _errorMessage = "Errore salvataggio: $e";
      // Rollback in caso di errore
      await loadPermessi();
    }
  }
}