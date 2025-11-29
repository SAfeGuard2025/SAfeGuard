import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../repositories/UserRepository.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Permesso.dart';
import 'package:data_models/Notifica.dart';
import 'package:data_models/Condizione.dart';
import 'package:data_models/ContattoEmergenza.dart';

// Lista domini Soccorritori (Allineata con LoginService e RegisterService)
const List<String> rescuerDomains = [
  '@soccorritore.com',
  '@soccorritore.gmail',
  '@crocerossa.it',
  '@118.it',
  '@protezionecivile.it',
];

class ProfileService {
  // Dipendenza dal Repository per l'accesso ai dati
  final UserRepository _userRepository = UserRepository();

  String _hashPassword(String password) {
    final secret = Platform.environment['HASH_SECRET'] ?? 'fallback_secret_dev';
    final bytes = utf8.encode(password + secret);
    return sha256.convert(bytes).toString();
  }

  // 1. GET Profilo
  // Recupera i dati grezzi e li trasforma nell'oggetto Utente/Soccorritore corretto
  Future<UtenteGenerico?> getProfile(int userId) async {
    try {
      // 1. Recupero dati dal Repository
      Map<String, dynamic>? data = await _userRepository.findUserById(userId);

      if (data != null) {
        final String email = data['email'] ?? '';

        // 2. Sicurezza: Rimuove l'hash della password prima di restituire i dati
        data.remove('passwordHash');

        // 3. Logica di classificazione
        final bool isSoccorritore = rescuerDomains.any((domain) => email.toLowerCase().endsWith(domain));

        if (isSoccorritore) {
          data['isSoccorritore'] = true; // Assicura il flag corretto
          return Soccorritore.fromJson(data);
        } else {
          return Utente.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print("Errore nel recupero profilo: $e");
      return null;
    }
  }

  // 2. UPDATE Permessi
  Future<bool> updatePermessi(int userId, Permesso permessi) async {
    try {
      // Delega al UserRepository l'aggiornamento del campo 'permessi' con il JSON dell'oggetto
      await _userRepository.updateUserField(userId, 'permessi', permessi.toJson());
      return true;
    } catch (e) {
      print("Errore update permessi: $e");
      return false;
    }
  }

  // 3. UPDATE Condizioni
  Future<bool> updateCondizioni(int userId, Condizione condizioni) async {
    try {
      // Delega al UserRepository l'aggiornamento del campo 'condizioni' con il JSON dell'oggetto
      await _userRepository.updateUserField(userId, 'condizioni', condizioni.toJson());
      return true;
    } catch (e) {
      print("Errore update condizioni: $e");
      return false;
    }
  }

  // 4. UPDATE Notifiche
  Future<bool> updateNotifiche(int userId, Notifica notifiche) async {
    try {
      // Delega al UserRepository l'aggiornamento del campo 'notifiche' con il JSON dell'oggetto
      await _userRepository.updateUserField(userId, 'notifiche', notifiche.toJson());
      return true;
    } catch (e) {
      print("Errore update notifiche: $e");
      return false;
    }
  }

  // 5. UPDATE Aanagrafica
  Future<bool> updateAnagrafica(int userId, {
    String? nome,
    String? cognome,
    String? telefono,
    String? citta,
    DateTime? dataNascita,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      // 1. Aggiornamenti campi semplici (solo se presenti)
      if (nome != null) updates['nome'] = nome;
      if (cognome != null) updates['cognome'] = cognome;
      if (citta != null) updates['cittaDiNascita'] = citta;
      if (dataNascita != null) updates['dataDiNascita'] = dataNascita.toIso8601String();

      // 2. Logica Email (Lowercase + Controllo Duplicati)
      if (email != null && email.isNotEmpty) {
        final normalizedEmail = email.toLowerCase();

        // Verifica se l'email è già usata da un ALTRO utente
        final existingUser = await _userRepository.findUserByEmail(normalizedEmail);
        if (existingUser != null && existingUser['id'] != userId) {
          print("Errore: Email $normalizedEmail già in uso.");
          return false;
        }
        updates['email'] = normalizedEmail;
      }

      // 3. Logica Telefono (No Spazi + Controllo Duplicati)
      if (telefono != null && telefono.isNotEmpty) {
        final cleanPhone = telefono.replaceAll(' ', '');

        // Verifica se il telefono è già usato da un altro utente
        final existingUser = await _userRepository.findUserByPhone(cleanPhone);
        if (existingUser != null && existingUser['id'] != userId) {
          print("Errore: Telefono $cleanPhone già in uso.");
          return false;
        }
        updates['telefono'] = cleanPhone;
      }

      // Esegue l'update solo se ci sono modifiche valide
      if (updates.isNotEmpty) {
        await _userRepository.updateUserGeneric(userId, updates);
      }
      return true;

    } catch (e) {
      print("Errore update anagrafica: $e");
      return false;
    }
  }

  // 6. Gestione Allergie
  Future<void> addAllergia(int userId, String allergia) async {
    await _userRepository.addToArrayField(userId, 'allergie', allergia);
  }

  Future<void> removeAllergia(int userId, String allergia) async {
    await _userRepository.removeFromArrayField(userId, 'allergie', allergia);
  }

  // 7. Gestione Medicinali
  Future<void> addMedicinale(int userId, String farmaco) async {
    await _userRepository.addToArrayField(userId, 'medicinali', farmaco);
  }

  Future<void> removeMedicinale(int userId, String farmaco) async {
    await _userRepository.removeFromArrayField(userId, 'medicinali', farmaco);
  }

  // 8. Gestione Contatti Emergenza
  Future<void> addContatto(int userId, ContattoEmergenza contatto) async {
    await _userRepository.addToArrayField(userId, 'contattiEmergenza', contatto.toJson());
  }

  Future<void> removeContatto(int userId, ContattoEmergenza contatto) async {
    await _userRepository.removeFromArrayField(userId, 'contattiEmergenza', contatto.toJson());
  }

  // 9. Gestione Account
  Future<String?> updatePassword(int userId, String oldPassword, String newPassword) async {
    try {
      final userData = await _userRepository.findUserById(userId);
      if (userData == null) return "Utente non trovato";

      await _userRepository.updateUserField(userId, 'passwordHash', _hashPassword(newPassword));
      return null;
    } catch (e) {
      return "Errore cambio password: $e";
    }
  }

  // 10. Eliminazione Account
  Future<bool> deleteAccount(int userId) async {
    try {
      return await _userRepository.deleteUser(userId);
    } catch (e) {
      print("Errore eliminazione account: $e");
      return false;
    }
  }

  // Inizializza i campi del profilo con valori di default se sono assenti
  Future<void> initializeUserProfile(int userId) async {
    try {
      final existingUser = await _userRepository.findUserById(userId);
      // Controlla se il profilo ha già i campi di default
      if (existingUser != null && existingUser['permessi'] == null) {
        print("🆕 Inizializzazione profilo default...");

        final String email = existingUser['email'] ?? '';
        final bool isSoccorritore = rescuerDomains.any((domain) => email.toLowerCase().endsWith(domain));

        // Crea gli oggetti modello con i valori di default
        final defaultPermessi = Permesso(
          posizione: false,
          contatti: false,
          notificheSistema: true,
          bluetooth: false,
        );
        final defaultCondizioni = Condizione();
        final defaultNotifiche = Notifica();

        // Mappa dei dati da inserire
        Map<String, dynamic> initData = {
          'permessi': defaultPermessi.toJson(),
          'condizioni': defaultCondizioni.toJson(),
          'notifiche': defaultNotifiche.toJson(),
          'allergie': [],
          'medicinali': [],
          'contattiEmergenza': [],
          'ruolo': isSoccorritore ? 'Soccorritore' : 'Cittadino',
          'isSoccorritore': isSoccorritore,
        };

        await _userRepository.updateUserGeneric(userId, initData);
        print("Profilo inizializzato con successo per ID: $userId");
      }
    } catch (e) {
      print("Errore inizializzazione: $e");
    }
  }
}