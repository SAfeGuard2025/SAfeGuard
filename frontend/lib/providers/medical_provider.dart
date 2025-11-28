import 'package:data_models/ContattoEmergenza.dart';
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

  List<MedicalItem> _medicinali = [];
  List<MedicalItem> get medicinali => _medicinali;

  // Carica medicinali
  Future<void> loadMedicines() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<String> strings = await _profileRepository.fetchMedicines();
      _medicinali = strings.map((e) => MedicalItem(name: e)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiunge medicinale
  Future<bool> addMedicinale(String nome) async {
    try {
      await _profileRepository.addMedicinale(nome);
      _medicinali.add(MedicalItem(name: nome));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Errore aggiunta: $e";
      notifyListeners();
      return false;
    }
  }

  // Rimuove medicinale
  Future<bool> removeMedicinale(int index) async {
    try {
      final item = _medicinali[index];
      await _profileRepository.removeMedicinale(item.name);

      _medicinali.removeAt(index);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Errore rimozione: $e";
      notifyListeners();
      return false;
    }
  }

  // ... dentro MedicalProvider ...

  List<ContattoEmergenza> _contatti = [];
  List<ContattoEmergenza> get contatti => _contatti;

  // Carica contatti
  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _contatti = await _profileRepository.fetchContacts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiungi contatto
  Future<bool> addContatto(String nome, String numero) async {
    try {
      final nuovoContatto = ContattoEmergenza(nome: nome, numero: numero);
      await _profileRepository.addContatto(nuovoContatto);

      _contatti.add(nuovoContatto);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Errore aggiunta contatto: $e";
      notifyListeners();
      return false;
    }
  }

  // Rimuovi contatto
  Future<bool> removeContatto(int index) async {
    try {
      final contatto = _contatti[index];
      await _profileRepository.removeContatto(contatto);

      _contatti.removeAt(index);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Errore rimozione contatto: $e";
      notifyListeners();
      return false;
    }
  }
}