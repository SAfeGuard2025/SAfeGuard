import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:collection/collection.dart';

// SIMULAZIONE DATABASE FIREBASE
// Normalmente, questa mappa sarebbe una collezione su Firebase Firestore.
// L'email è usata come ID unico per la semplicità del login.
final Map<String, Map<String, dynamic>> _simulatedDatabase = {
  // Utente Standard (Login tramite Email)
  'mario.rossi@gmail.com': {
    'id': 101,
    'email': 'mario.rossi@gmail.com',
    'telefono': '+393331234567',
    'passwordHash': 'password123',
    'nome': 'Mario',
    'cognome': 'Rossi',
  },
  // Utente Solo Telefono (Simulato, la chiave è ancora l'email per consistenza)
  'solo.telefono@gmail.com': { // Email placeholder, non usata per il login
    'id': 103,
    'email': 'solo.telefono@gmail.com',
    'telefono': '+393457654321', // Numero di telefono usato per il login
    'passwordHash': 'telefono_pass',
    'nome': 'Anna',
    'cognome': 'B.',
  },
  // Soccorritore (Login tramite Email discriminante)
  'luca.verdi@soccorritore.gmail': {
    'id': 202,
    'email': 'luca.verdi@soccorritore.gmail',
    'passwordHash': 'password456',
    'nome': 'Luca',
    'cognome': 'Verdi',
  },
};

class UserRepository {
  // 1. Simula l'interazione con il DB per trovare un utente tramite email
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    // La ricerca in un vero DB avverrebbe con una query WHERE email == $email
    return _simulatedDatabase[email];
  }

  // 1. Simula l'interazione con il DB per trovare un utente tramite telefono
  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    // Restituisce il primo elemento o null se nessun elemento soddisfa la condizione.
    return _simulatedDatabase.values.firstWhereOrNull(
          (user) => user['telefono'] == phone,
    );
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