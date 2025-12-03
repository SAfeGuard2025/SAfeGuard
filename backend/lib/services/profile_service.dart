import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../config/rescuer_config.dart';
import '../repositories/user_repository.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';
import 'package:data_models/utente_generico.dart';
import 'package:data_models/permesso.dart';
import 'package:data_models/notifica.dart';
import 'package:data_models/condizione.dart';
import 'package:data_models/contatto_emergenza.dart';

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
      Map<String, dynamic>? data = await _userRepository.findUserById(userId);

      if (data != null) {
        final String email = data['email'] ?? '';
        data.remove('passwordHash');

        final bool isSoccorritore = RescuerConfig.isSoccorritore(email);

        if (isSoccorritore) {
          data['isSoccorritore'] = true;
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
      await _userRepository.updateUserField(
        userId,
        'permessi',
        permessi.toJson(),
      );
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
      await _userRepository.updateUserField(
        userId,
        'condizioni',
        condizioni.toJson(),
      );
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
      await _userRepository.updateUserField(
        userId,
        'notifiche',
        notifiche.toJson(),
      );
      return true;
    } catch (e) {
      print("Errore update notifiche: $e");
      return false;
    }
  }

  // 5. UPDATE Aanagrafica
  Future<bool> updateAnagrafica(
    int userId, {
    String? nome,
    String? cognome,
    String? telefono,
    String? citta,
    DateTime? dataNascita,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      final currentUserData = await _userRepository.findUserById(userId);
      if (currentUserData == null) return false;

      final String currentEmail = (currentUserData['email'] as String? ?? '')
          .toLowerCase();

      // Aggiornamenti campi semplici
      if (nome != null) updates['nome'] = nome;
      if (cognome != null) updates['cognome'] = cognome;
      if (citta != null) updates['cittaDiNascita'] = citta;
      if (dataNascita != null) {
        updates['dataDiNascita'] = dataNascita.toIso8601String();
      }

      //Logica Email
      if (email != null && email.isNotEmpty) {
        final normalizedNewEmail = email.toLowerCase();
        if (normalizedNewEmail != currentEmail) {
          if (RescuerConfig.isSoccorritore(normalizedNewEmail)) {
            print(
              "Errore: Impossibile passare a un'email istituzionale riservata.",
            );
            return false;
          }
          final existingUser = await _userRepository.findUserByEmail(
            normalizedNewEmail,
          );
          if (existingUser != null) {
            print("Errore: Email $normalizedNewEmail già in uso.");
            return false;
          }
          updates['email'] = normalizedNewEmail;
        }
      }

      if (telefono != null && telefono.isNotEmpty) {
        final cleanPhone = telefono.replaceAll(' ', '');
        final currentPhone = (currentUserData['telefono'] as String?) ?? '';

        if (cleanPhone != currentPhone) {
          final existingUser = await _userRepository.findUserByPhone(
            cleanPhone,
          );
          if (existingUser != null && existingUser['id'] != userId) {
            print("Errore: Telefono $cleanPhone già in uso.");
            return false;
          }
          updates['telefono'] = cleanPhone;
        }
      }

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
    await _userRepository.addToArrayField(
      userId,
      'contattiEmergenza',
      contatto.toJson(),
    );
  }

  Future<void> removeContatto(int userId, ContattoEmergenza contatto) async {
    await _userRepository.removeFromArrayField(
      userId,
      'contattiEmergenza',
      contatto.toJson(),
    );
  }

  // 9. Gestione Account
  Future<String?> updatePassword(
    int userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final userData = await _userRepository.findUserById(userId);
      if (userData == null) return "Utente non trovato";

      await _userRepository.updateUserField(
        userId,
        'passwordHash',
        _hashPassword(newPassword),
      );
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

  // Inizializza Profilo
  Future<void> initializeUserProfile(int userId) async {
    try {
      final existingUser = await _userRepository.findUserById(userId);
      if (existingUser != null && existingUser['permessi'] == null) {
        print("🆕 Inizializzazione profilo default...");

        final String email = existingUser['email'] ?? '';
        final bool isSoccorritore = RescuerConfig.isSoccorritore(email);

        final defaultPermessi = Permesso(
          posizione: false,
          contatti: false,
          notificheSistema: true,
          bluetooth: false,
        );
        final defaultCondizioni = Condizione();
        final defaultNotifiche = Notifica();

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

  // 11. AGGIORNAMENTO TOKEN FCM
  Future<void> updateFCMToken(int userId, String tokenFCM) async {
    try {
      await _userRepository.updateUserField(userId, 'tokenFCM', tokenFCM);
    } catch (e) {
      print("Errore aggiornamento token FCM per ID $userId: $e");
    }
  }

  // 12. AGGIORNAMENTO POSIZIONE GPS (Nuova Funzionalità)
  // Questo metodo salva latitudine e longitudine nel DB per le notifiche di prossimità
  Future<void> updatePosition(int userId, double lat, double lng) async {
    try {
      await _userRepository.updateUserLocation(userId, lat, lng);
    } catch (e) {
      print("Errore aggiornamento posizione per ID $userId: $e");
    }
  }
}
