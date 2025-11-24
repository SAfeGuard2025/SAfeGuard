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
    'isVerified': 'false',
    'otp': 'xxxx',
  },
  // Utente Solo Telefono (Simulato, la chiave è ancora l'email per consistenza)
  'solo.telefono@gmail.com': {
    // Email placeholder, non usata per il login
    'id': 103,
    'email': 'solo.telefono@gmail.com',
    'telefono': '+393457654321', // Numero di telefono usato per il login
    'passwordHash': 'telefono_pass',
    'nome': 'Anna',
    'cognome': 'B.',
    'isVerified': 'false',
    'otp': 'xxxx',
  },
  // Soccorritore (Login tramite Email discriminante)
  'luca.verdi@soccorritore.gmail': {
    'id': 202,
    'email': 'luca.verdi@soccorritore.gmail',
    'passwordHash': 'password456',
    'nome': 'Luca',
    'cognome': 'Verdi',
    'isVerified': 'false',
    'otp': 'xxxx',
  },
};

class UserRepository {
  // Mappa temporanea in memoria per la simulazione dell'OTP
  static final Map<String, String> _otpCache = {};

  // Simula l'interazione con il DB per trovare un utente tramite email
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    // La ricerca in un vero DB avverrebbe con una query WHERE email == $email
    return _simulatedDatabase[email];
  }

  // Simula l'interazione con il DB per trovare un utente tramite telefono
  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    // Restituisce il primo elemento o null se nessun elemento soddisfa la condizione.
    return _simulatedDatabase.values.firstWhereOrNull(
      (user) => user['telefono'] == phone,
    );
  }

  // Questo metodo riceve la mappa grezza creata nel LoginService,
  // assegna un ID e salva nel DB simulato.
  Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> userData, {
    required String collection,
  }) async {
    final email = userData['email'] as String;

    // Controllo di sicurezza base
    if (_simulatedDatabase.containsKey(email)) {
      throw Exception('Utente già esistente');
    }

    // 1. Simulazione generazione ID (in Firebase sarebbe automatico o un UUID)
    final int newId = _simulatedDatabase.length + 300;

    userData['id'] = newId;

    // Nota: In Firebase reale:
    // await FirebaseFirestore.instance.collection(collection).add(userData);

    // 2. Salvataggio nella simulazione
    _simulatedDatabase[email] = userData;

    print(
      'Nuovo utente Google creato: ${userData['nome']} ($email) con ID $newId nella collezione $collection',
    );

    return userData;
  }

  //Salva l'OTP nel DB (o in cache)
  Future<void> saveOtp(String telefono, String otp) async {
    // In un ambiente reale: questo salverebbe OTP e scadenza su Firebase o Redis.
    print('OTP SALVATO IN CACHE per $telefono: $otp');
    // Nella simulazione, possiamo usare una mappa temporanea in memoria:
    _otpCache[telefono] = otp;
  }

  // Verifica l'OTP
  Future<bool> verifyOtp(String telefono, String otp) async {
    // In un ambiente reale: controllerebbe OTP e scadenza.
    final storedOtp = _otpCache[telefono];
    _otpCache.remove(telefono); // L'OTP può essere usato solo una volta
    return storedOtp == otp;
  }

  //Aggiorna lo stato di verifica dell'utente
  Future<void> markUserAsVerified(String email) async {
    // In un ambiente reale: aggiornerebbe il campo 'isVerified' nel DB a true.
    if (_simulatedDatabase.containsKey(email.toLowerCase())) {
      _simulatedDatabase[email.toLowerCase()]!['isVerified'] = true;
      print('Utente $email marcato come VERIFICATO.');
    }
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
    if (userData['email'].toString().toLowerCase().endsWith(
      '@soccorritore.gmail',
    )) {
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
