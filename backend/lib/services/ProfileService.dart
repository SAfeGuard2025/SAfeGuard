import '../repositories/UserRepository.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:data_models/Permesso.dart';
import 'package:data_models/Notifica.dart';
import 'package:data_models/Condizione.dart';
import 'package:data_models/ContattoEmergenza.dart';

class ProfileService {
  // Sostituito FirebaseFirestore con il nostro Repository custom.
  // Questo rende il service agnostico rispetto al DB reale (SQL/NoSQL/Memoria).
  final UserRepository _userRepository = UserRepository();

  static const String rescuerDomain = '@soccorritore.com';

  // --- 1. GET PROFILE ---
  // Importante: Accettiamo 'int userId' e restituiamo 'UtenteGenerico'.
  // Questo perché non sappiamo a priori se stiamo caricando un Cittadino o un Soccorritore.
  Future<UtenteGenerico?> getProfile(int userId) async {
    try {
      // Recupero raw data dal repository
      Map<String, dynamic>? data = await _userRepository.findUserById(userId);

      if (data != null) {
        final String email = data['email'] ?? '';

        // Sicurezza: Rimuoviamo l'hash della password prima che arrivi alla UI
        data.remove('passwordHash');

        // Polimorfismo Manuale:
        // In base al dominio dell'email, decidiamo quale Classe istanziare.
        if (email.toLowerCase().endsWith(rescuerDomain)) {
          return Soccorritore.fromJson(data);
        } else {
          // Se è un utente normale, Utente.fromJson parserà anche i campi complessi (permessi, liste, ecc.)
          return Utente.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print("Errore nel recupero profilo: $e");
      return null;
    }
  }

  // --- 2. UPDATE PERMESSI (Oggetto intero) ---
  // Sostituisce l'intero blocco 'permessi' nel DB con quello nuovo.
  Future<bool> updatePermessi(int userId, Permesso permessi) async {
    try {
      await _userRepository.updateUserField(userId, 'permessi', permessi.toJson());
      return true;
    } catch (e) {
      print("Errore update permessi: $e");
      return false;
    }
  }

  // --- 3. UPDATE CONDIZIONI (Oggetto intero) ---
  Future<bool> updateCondizioni(int userId, Condizione condizioni) async {
    try {
      await _userRepository.updateUserField(userId, 'condizioni', condizioni.toJson());
      return true;
    } catch (e) {
      print("Errore update condizioni: $e");
      return false;
    }
  }

  // --- 4. UPDATE NOTIFICHE (Oggetto intero) ---
  Future<bool> updateNotifiche(int userId, Notifica notifiche) async {
    try {
      await _userRepository.updateUserField(userId, 'notifiche', notifiche.toJson());
      return true;
    } catch (e) {
      print("Errore update notifiche: $e");
      return false;
    }
  }

  // --- 5. UPDATE ANAGRAFICA (Aggiornamento parziale) ---
  // Qui aggiorniamo solo i campi passati, lasciando null quelli che non cambiano.
// Modifica la firma del metodo per accettare 'email'
  Future<bool> updateAnagrafica(int userId, {
    String? nome,
    String? cognome,
    String? telefono,
    String? citta,
    DateTime? dataNascita,
    String? email, // <--- AGGIUNTO
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (nome != null) updates['nome'] = nome;
      if (cognome != null) updates['cognome'] = cognome;
      if (telefono != null) updates['telefono'] = telefono;
      if (citta != null) updates['cittaDiNascita'] = citta;
      if (dataNascita != null) updates['dataDiNascita'] = dataNascita.toIso8601String();

      // Aggiungiamo l'aggiornamento email
      if (email != null && email.isNotEmpty) updates['email'] = email; // <--- AGGIUNTO

      if (updates.isNotEmpty) {
        await _userRepository.updateUserGeneric(userId, updates);
      }
      return true;
    } catch (e) {
      print("Errore anagrafica: $e");
      return false;
    }
  }
  // --- 6. GESTIONE ALLERGIE (Liste) ---
  // Mappiamo le aggiunte/rimozioni sugli array del repository.
  Future<void> addAllergia(int userId, String allergia) async {
    await _userRepository.addToArrayField(userId, 'allergie', allergia);
  }

  Future<void> removeAllergia(int userId, String allergia) async {
    await _userRepository.removeFromArrayField(userId, 'allergie', allergia);
  }

  // --- 7. GESTIONE MEDICINALI (Liste) ---
  Future<void> addMedicinale(int userId, String farmaco) async {
    await _userRepository.addToArrayField(userId, 'medicinali', farmaco);
  }

  Future<void> removeMedicinale(int userId, String farmaco) async {
    await _userRepository.removeFromArrayField(userId, 'medicinali', farmaco);
  }

  // --- 8. GESTIONE CONTATTI EMERGENZA (Liste Complesse) ---
  Future<void> addContatto(int userId, ContattoEmergenza contatto) async {
    await _userRepository.addToArrayField(userId, 'contattiEmergenza', contatto.toJson());
  }

  Future<void> removeContatto(int userId, ContattoEmergenza contatto) async {
    // Nota: Il repository usa un confronto JSON per rimuovere l'oggetto corretto.
    await _userRepository.removeFromArrayField(userId, 'contattiEmergenza', contatto.toJson());
  }

  // --- 9. GESTIONE ACCOUNT (Password & Delete) ---
  Future<String?> updatePassword(int userId, String oldPassword, String newPassword) async {
    try {
      final userData = await _userRepository.findUserById(userId);
      if (userData == null) return "Utente non trovato";

      final String storedHash = userData['passwordHash'] ?? '';

      // Simulazione verifica hash. In produzione usare bcrypt.
      if (storedHash != oldPassword) {
        return "La vecchia password non è corretta";
      }

      await _userRepository.updateUserField(userId, 'passwordHash', newPassword);
      return null; // Null = Successo
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

  // --- INIZIALIZZAZIONE (Seeding) ---
  // Metodo cruciale: se un utente si è appena registrato (es. Login Rapido Google),
  // il suo profilo nel DB potrebbe essere incompleto (mancano liste, permessi).
  // Questo metodo crea la struttura di default.
  Future<void> initializeUserProfile(int userId) async {
    try {
      final existingUser = await _userRepository.findUserById(userId);

      // Usiamo l'assenza del campo 'permessi' come flag per capire se l'utente è "nuovo"
      if (existingUser != null && existingUser['permessi'] == null) {
        print("🆕 Inizializzazione profilo default...");

        final defaultPermessi = Permesso(
          posizione: false,
          contatti: false,
          notificheSistema: true,
          bluetooth: false,
        );

        final defaultCondizioni = Condizione(); // Tutto false di default
        final defaultNotifiche = Notifica(); // Push attive di default

        Map<String, dynamic> initData = {
          'permessi': defaultPermessi.toJson(),
          'condizioni': defaultCondizioni.toJson(),
          'notifiche': defaultNotifiche.toJson(),
          'allergie': [],
          'medicinali': [],
          'contattiEmergenza': [],
          'ruolo': 'Cittadino',
        };

        await _userRepository.updateUserGeneric(userId, initData);
        print("Profilo inizializzato con successo per ID: $userId");
      }
    } catch (e) {
      print("Errore inizializzazione: $e");
    }
  }
}