import 'package:firedart/firedart.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'dart:convert';

class UserRepository {
  // Collezione Firestore di riferimento
  CollectionReference get _usersCollection => Firestore.instance.collection('users');

  // --- LETTURA ---

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    // Query su Firestore invece che mappa in memoria [cite: 76]
    final pages = await _usersCollection.where('email', isEqualTo: email).get();

    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    // Query su Firestore per telefono [cite: 77]
    final pages = await _usersCollection.where('telefono', isEqualTo: phone).get();

    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  Future<Map<String, dynamic>?> findUserById(int id) async {
    // Query su Firestore per ID numerico [cite: 94]
    final pages = await _usersCollection.where('id', isEqualTo: id).get();

    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  // --- SCRITTURA (Create/Update) ---

  Future<UtenteGenerico> saveUser(UtenteGenerico newUser) async {
    if (newUser.email == null) throw Exception('Email mancante.');

    // Generazione ID incrementale (Logica base per dev, in prod usare UUID o ID Firestore)
    // Nota: Firestore non supporta "count" nativo veloce su collezioni enormi senza aggregazioni,
    // ma per dev va bene prendere una lista o usare un contatore atomico.
    // Qui usiamo un timestamp int per unicità semplice in dev.
    final newId = DateTime.now().millisecondsSinceEpoch;

    final userData = newUser.toJson();
    userData['id'] = newId;

    // Salvataggio su Firestore usando l'email come Document ID per unicità facile
    await _usersCollection.document(newUser.email!).set(userData);


    // Lista locale o importata (se vuoi puoi metterla in cima al file o in un file SharedConstants.dart)
    const List<String> rescuerDomains = [
      '@soccorritore.gmail',
      '@crocerossa.it',
      '@118.it',
      '@protezionecivile.it',
    ];


    // Ricostruzione oggetto con controllo sulla lista
    final String email = userData['email'].toString().toLowerCase();
    final bool isSoccorritore = rescuerDomains.any((domain) => email.endsWith(domain));

    if (isSoccorritore) {
      return Soccorritore.fromJson(userData);
    } else {
      return Utente.fromJson(userData);
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData, {required String collection}) async {
    final email = userData['email'] as String;

    // Verifica esistenza
    if (await findUserByEmail(email) != null) {
      throw Exception('Utente già esistente'); // [cite: 83]
    }

    final int newId = DateTime.now().millisecondsSinceEpoch; // Sostituisce logica +300
    userData['id'] = newId;

    await _usersCollection.document(email).set(userData);
    return userData;
  }

  // --- AGGIORNAMENTI (Profile Service) ---

  Future<void> updateUserGeneric(int id, Map<String, dynamic> updates) async {
    // 1. Trova il documento Firestore corrispondente all'ID numerico
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update(updates); // [cite: 96]
    } else {
      throw Exception("Utente con ID $id non trovato.");
    }
  }

  Future<void> updateUserField(int id, String fieldName, dynamic value) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update({fieldName: value}); // [cite: 100]
    }
  }

  // --- GESTIONE ARRAY (Firestore) ---

  // Firedart non supporta nativamente ArrayUnion/ArrayRemove in modo atomico perfetto come l'SDK Admin,
  // quindi leggiamo, modifichiamo e riscriviamo (accettabile per dev/traffico basso).

  Future<void> addToArrayField(int id, String fieldName, dynamic item) async {
    final docId = await _findDocIdByIntId(id);
    if (docId == null) return;

    final doc = await _usersCollection.document(docId).get();
    List<dynamic> list = (doc.map[fieldName] as List<dynamic>?)?.toList() ?? [];

    list.add(item);
    await _usersCollection.document(docId).update({fieldName: list}); // [cite: 104]
  }

  Future<void> removeFromArrayField(int id, String fieldName, dynamic item) async {
    final docId = await _findDocIdByIntId(id);
    if (docId == null) return;

    final doc = await _usersCollection.document(docId).get();
    List<dynamic> list = (doc.map[fieldName] as List<dynamic>?)?.toList() ?? [];

    final itemJson = jsonEncode(item);
    list.removeWhere((element) => jsonEncode(element) == itemJson); // [cite: 111]

    await _usersCollection.document(docId).update({fieldName: list});
  }

  Future<bool> deleteUser(int id) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).delete(); // [cite: 113]
      return true;
    }
    return false;
  }

  // --- OTP CACHE ---
  // Per l'OTP, in un server reale scalabile si userebbe Redis.
  // Per ora manteniamo la memoria statica o scriviamo su una collezione temporanea Firestore 'otps'.
  // Manteniamo memoria per semplicità come da codice originale.
  static final Map<String, String> _otpCache = {};

  Future<void> saveOtp(String telefono, String otp) async {
    _otpCache[telefono] = otp; // [cite: 85]
  }

  Future<bool> verifyOtp(String telefono, String otp) async {
    final storedOtp = _otpCache[telefono];
    _otpCache.remove(telefono);
    return storedOtp == otp; // [cite: 87]
  }

  Future<void> markUserAsVerified(String email) async {
    // Cerca per email direttamente (usata come ID documento sopra)
    try {
      await _usersCollection.document(email).update({'isVerified': true});
    } catch (e) {
      // Fallback se l'email non corrisponde al doc ID, cerca per campo
      final pages = await _usersCollection.where('email', isEqualTo: email).get();
      if (pages.isNotEmpty) {
        await _usersCollection.document(pages.first.id).update({'isVerified': true});
      }
    }
  }

  // Helper per trovare il Document ID (stringa) partendo dall'ID numerico interno
  Future<String?> _findDocIdByIntId(int id) async {
    final pages = await _usersCollection.where('id', isEqualTo: id).get();
    if (pages.isNotEmpty) {
      return pages.first.id;
    }
    return null;
  }
}