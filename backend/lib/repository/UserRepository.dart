import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';

// SIMULAZIONE DATABASE FIREBASE
// Normalmente, questa mappa sarebbe una collezione su Firebase Firestore.
// L'email è usata come ID unico per la semplicità del login.
final Map<String, Map<String, dynamic>> _simulatedDatabase = {
  // Utente Standard
  'user@example.com': {
    'id': 101,
    'email': 'user@example.com',
    'passwordHash': 'hashed_password_for_user', // Hash simulato
    'nome': 'Mario',
    'cognome': 'Rossi',
  },
  // Soccorritore
  'rescue@example.com': {
    'id': 202,
    'email': 'rescue@soccorritore.com',
    'passwordHash': 'hashed_password_for_rescue', // Hash simulato
    'nome': 'Luca',
    'cognome': 'Verdi',
    'tipoUtente': 'Soccorritore', // Campo discriminante per la deserializzazione
  },
};

class UserRepository {
  // 1. Simula l'interazione con il DB per trovare un utente tramite email
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    // La ricerca in un vero DB avverrebbe con una query WHERE email == $email
    return _simulatedDatabase[email];
  }

  Future<UtenteGenerico> saveUser(UtenteGenerico newUser) async {
    if (newUser.email == null) {
      throw Exception('Impossibile salvare un utente senza email.');
    }

    // Assegna un ID unico (simulazione)
    final newId = _simulatedDatabase.length + 1000;

    // Crea il payload con l'ID assegnato
    final userData = newUser.toJson();
    userData['id'] = newId;

    // Crea una nuova istanza con l'ID assegnato
    final UtenteGenerico userWithId;
    if (userData['email'].toString().toLowerCase().endsWith('@soccorritore.gmail')) {
      // Uso fromJson per ricreare il modello con l'ID
      userWithId = Soccorritore.fromJson(userData);
    } else {
      userWithId = Utente.fromJson(userData);
    }

    // Salva nel DB simulato
    _simulatedDatabase[userWithId.email!.toLowerCase()] = userWithId.toJson();

    return userWithId;
  }
}