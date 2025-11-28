import '../repositories/UserRepository.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Permesso.dart';
import 'package:data_models/Notifica.dart';
import 'package:data_models/Condizione.dart';
import 'package:data_models/ContattoEmergenza.dart';

class ProfileService {
  final UserRepository _userRepository = UserRepository();

  // LISTA DOMINI SOCCORRITORI (Deve coincidere con LoginService e RegisterService)
  static const List<String> rescuerDomains = [
    '@soccorritore.com',
    '@soccorritore.gmail',
    '@crocerossa.it',
    '@118.it',
    '@protezionecivile.it',
  ];

  // --- 1. GET PROFILE ---
  Future<UtenteGenerico?> getProfile(int userId) async {
    try {
      // Recupero raw data dal repository
      Map<String, dynamic>? data = await _userRepository.findUserById(userId);

      if (data != null) {
        final String email = data['email'] ?? '';

        // Sicurezza: Rimuoviamo l'hash della password
        data.remove('passwordHash');

        // Polimorfismo Manuale: controlla se l'email corrisponde a QUALSIASI dominio soccorritore
        final bool isSoccorritore = rescuerDomains.any((domain) => email.toLowerCase().endsWith(domain));

        if (isSoccorritore) {
          // Forza il flag a true nel caso mancasse nel DB
          data['isSoccorritore'] = true;
          return Soccorritore.fromJson(data);
        } else {
          // Se è un utente normale
          return Utente.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print("Errore nel recupero profilo: $e");
      return null;
    }
  }

  // --- 2. UPDATE PERMESSI ---
  Future<bool> updatePermessi(int userId, Permesso permessi) async {
    try {
      await _userRepository.updateUserField(userId, 'permessi', permessi.toJson());
      return true;
    } catch (e) {
      print("Errore update permessi: $e");
      return false;
    }
  }

  // --- 3. UPDATE CONDIZIONI ---
  Future<bool> updateCondizioni(int userId, Condizione condizioni) async {
    try {
      await _userRepository.updateUserField(userId, 'condizioni', condizioni.toJson());
      return true;
    } catch (e) {
      print("Errore update condizioni: $e");
      return false;
    }
  }

  // --- 4. UPDATE NOTIFICHE ---
  Future<bool> updateNotifiche(int userId, Notifica notifiche) async {
    try {
      await _userRepository.updateUserField(userId, 'notifiche', notifiche.toJson());
      return true;
    } catch (e) {
      print("Errore update notifiche: $e");
      return false;
    }
  }

  // --- 5. UPDATE ANAGRAFICA ---
  Future<bool> updateAnagrafica(int userId, {
    String? nome,
    String? cognome,
    String? telefono,
    String? citta,
    DateTime? dataNascita,
    String? email,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (nome != null) updates['nome'] = nome;
      if (cognome != null) updates['cognome'] = cognome;
      if (telefono != null) updates['telefono'] = telefono;
      if (citta != null) updates['cittaDiNascita'] = citta;
      if (dataNascita != null) updates['dataDiNascita'] = dataNascita.toIso8601String();
      if (email != null && email.isNotEmpty) updates['email'] = email;

      if (updates.isNotEmpty) {
        await _userRepository.updateUserGeneric(userId, updates);
      }
      return true;
    } catch (e) {
      print("Errore anagrafica: $e");
      return false;
    }
  }

  // --- 6. GESTIONE ALLERGIE ---
  Future<void> addAllergia(int userId, String allergia) async {
    await _userRepository.addToArrayField(userId, 'allergie', allergia);
  }

  Future<void> removeAllergia(int userId, String allergia) async {
    await _userRepository.removeFromArrayField(userId, 'allergie', allergia);
  }

  // --- 7. GESTIONE MEDICINALI ---
  Future<void> addMedicinale(int userId, String farmaco) async {
    await _userRepository.addToArrayField(userId, 'medicinali', farmaco);
  }

  Future<void> removeMedicinale(int userId, String farmaco) async {
    await _userRepository.removeFromArrayField(userId, 'medicinali', farmaco);
  }

  // --- 8. GESTIONE CONTATTI EMERGENZA ---
  Future<void> addContatto(int userId, ContattoEmergenza contatto) async {
    await _userRepository.addToArrayField(userId, 'contattiEmergenza', contatto.toJson());
  }

  Future<void> removeContatto(int userId, ContattoEmergenza contatto) async {
    await _userRepository.removeFromArrayField(userId, 'contattiEmergenza', contatto.toJson());
  }

  // --- 9. GESTIONE ACCOUNT ---
  Future<String?> updatePassword(int userId, String oldPassword, String newPassword) async {
    try {
      final userData = await _userRepository.findUserById(userId);
      if (userData == null) return "Utente non trovato";

      final String storedHash = userData['passwordHash'] ?? '';

      await _userRepository.updateUserField(userId, 'passwordHash', newPassword);
      return null;
    } catch (e) {
      return "Errore cambio password: $e";
    }
  }

  Future<bool> deleteAccount(int userId) async {
    try {
      return await _userRepository.deleteUser(userId);
    } catch (e) {
      print("Errore eliminazione account: $e");
      return false;
    }
  }

  // --- INIZIALIZZAZIONE ---
  Future<void> initializeUserProfile(int userId) async {
    try {
      final existingUser = await _userRepository.findUserById(userId);
      // Usiamo l'assenza del campo 'permessi' come flag per capire se l'utente è "nuovo"
      if (existingUser != null && existingUser['permessi'] == null) {
        print("🆕 Inizializzazione profilo default...");

        // Verifica se è soccorritore per eventuali default diversi
        final String email = existingUser['email'] ?? '';
        final bool isSoccorritore = rescuerDomains.any((domain) => email.toLowerCase().endsWith(domain));

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
}