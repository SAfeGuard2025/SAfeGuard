import 'package:data_models/Condizione.dart';
import 'package:data_models/ContattoEmergenza.dart';
import 'package:flutter/material.dart';
import 'package:data_models/medical_item.dart';
import '../repositories/profile_repository.dart';

// Provider di Stato: MedicalProvider
// Gestisce lo stato e la logica per le sezioni mediche e contatti del profilo utente.
class MedicalProvider extends ChangeNotifier {
  // Dipendenze: Repository per la comunicazione col Backend (API)
  final ProfileRepository _profileRepository = ProfileRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<MedicalItem> _allergie = [];
  List<MedicalItem> get allergie => _allergie;

  // Carica la lista delle allergie dal DB
  Future<void> loadAllergies() async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Delega a ProfileRepository la fetch delle stringhe
      final List<String> strings = await _profileRepository.fetchAllergies();
      // 2. Mappa le stringhe in oggetti MedicalItem per la UI
      _allergie = strings.map((e) => MedicalItem(name: e)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiunge una nuova allergia al DB e aggiorna lo stato locale
  Future<bool> addAllergia(String nome) async {
    try {
      //Delega a ProfileRepository l'aggiunta
      await _profileRepository.addAllergia(nome);
      _allergie.add(MedicalItem(name: nome));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Errore aggiunta: $e";
      notifyListeners();
      return false;
    }
  }

  // Rimuove un'allergia dal DB e aggiorna lo stato locale
  Future<bool> removeAllergia(int index) async {
    try {
      final item = _allergie[index];
      //Delega a ProfileRepository la rimozione
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

  // Carica la lista dei medicinali dal DB
  Future<void> loadMedicines() async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Delega a ProfileRepository la fetch delle stringhe
      final List<String> strings = await _profileRepository.fetchMedicines();
      // 2. Mappa le stringhe in oggetti MedicalItem per la UI
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
      //Delega a ProfileRepository l'aggiunta
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
      //Delega a ProfileRepository la rimozione
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

  List<ContattoEmergenza> _contatti = [];
  List<ContattoEmergenza> get contatti => _contatti;

  // Carica la lista di ContattiEmergenza
  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Delega a ProfileRepository la fetch dei contatti
      _contatti = await _profileRepository.fetchContacts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiunge un ContattoEmergenza
  Future<bool> addContatto(String nome, String numero) async {
    try {
      final nuovoContatto = ContattoEmergenza(nome: nome, numero: numero);
      // Delega a ProfileRepository l'aggiunta
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
      // Delega a ProfileRepository la rimozione
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

  Condizione _condizioni = Condizione();
  Condizione get condizioni => _condizioni;

  // Carica Condizioni
  Future<void> loadCondizioni() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Delega a ProfileRepository la fetch delle condizioni
      _condizioni = await _profileRepository.fetchCondizioni();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Aggiornamento (Toggle Switch)
  Future<void> updateCondizioni(Condizione nuoveCondizioni) async {
    _condizioni = nuoveCondizioni;
    notifyListeners();

    try {
      // Delega a ProfileRepository l'aggiornamento
      await _profileRepository.updateCondizioni(nuoveCondizioni);
    } catch (e) {
      _errorMessage = "Errore salvataggio: $e";
      // Rollback in caso di errore
      await loadCondizioni();
    }
  }
}