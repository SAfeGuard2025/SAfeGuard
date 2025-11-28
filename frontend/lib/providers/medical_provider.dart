import 'package:flutter/material.dart';
import 'package:data_models/medical_item.dart';
import '../repositories/profile_repository.dart'; // Importa il repo creato sopra

class MedicalProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();

  List<MedicalItem> _allergie = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicalItem> get allergie => _allergie;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Carica allergie all'avvio della schermata
  Future<void> loadAllergies() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<String> strings = await _profileRepository.fetchAllergies();
      // Convertiamo le stringhe dal DB in oggetti MedicalItem per la UI
      _allergie = strings.map((e) => MedicalItem(name: e)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiunge al DB e aggiorna la UI
  Future<bool> addAllergia(String nome) async {
    try {
      await _profileRepository.addAllergia(nome);
      // Aggiorniamo la lista locale solo se il server ha risposto OK
      _allergie.add(MedicalItem(name: nome));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Errore aggiunta: $e";
      notifyListeners();
      return false;
    }
  }

  // Rimuove dal DB e aggiorna la UI
  Future<bool> removeAllergia(int index) async {
    try {
      final item = _allergie[index];
      await _profileRepository.removeAllergia(item.name);

      _allergie.removeAt(index);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Errore rimozione: $e";
      notifyListeners();
      return false;
    }
  }
}