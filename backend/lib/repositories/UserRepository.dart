import 'package:firedart/firedart.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'dart:convert';

class UserRepository {
  CollectionReference get _usersCollection => Firestore.instance.collection('users');
  CollectionReference get _phoneVerifications => Firestore.instance.collection('phone_verifications');

  // --- LETTURA (FIND) ---

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final pages = await _usersCollection.where('email', isEqualTo: email).get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    final pages = await _usersCollection.where('telefono', isEqualTo: phone).get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  Future<Map<String, dynamic>?> findUserById(int id) async {
    final pages = await _usersCollection.where('id', isEqualTo: id).get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }


  Future<UtenteGenerico> saveUser(UtenteGenerico newUser) async {
    final int newId = DateTime.now().millisecondsSinceEpoch;
    final userData = newUser.toJson();
    userData['id'] = newId;

    // --- MODIFICA QUI ---
    // Usiamo direttamente l'ID generato come nome del documento
    final String docId = newId.toString();
    // --------------------

    await _usersCollection.document(docId).set(userData);

    if (newUser is Soccorritore || (userData['isSoccorritore'] == true)) {
      return Soccorritore.fromJson(userData);
    } else {
      return Utente.fromJson(userData);
    }
  }

  // --- CREATE USER (Usato da LoginService per Google/Apple) ---
  // Questo metodo mancava e causava l'errore nello screenshot
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData, {String collection = 'users'}) async {
    // Genera ID se manca
    if (userData['id'] == null || userData['id'] == 0) {
      userData['id'] = DateTime.now().millisecondsSinceEpoch;
    }

    // --- MODIFICA QUI ---
    // Indipendentemente da email o telefono, usiamo l'ID
    final String docId = userData['id'].toString();
    // --------------------

    // Salvataggio
    await Firestore.instance.collection(collection).document(docId).set(userData);

    return userData;
  }

  // --- AGGIORNAMENTI PROFILO ---

  Future<String?> _findDocIdByIntId(int id) async {
    final docId = id.toString();

    try {
      // In Firedart, se il documento non c'è, questa riga lancia un errore
      await _usersCollection.document(docId).get();
      return docId;
    } catch (e) {
      // Se entra qui, il documento non esiste
      return null;
    }
  }

  Future<void> updateUserGeneric(int id, Map<String, dynamic> updates) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update(updates);
    } else {
      throw Exception("Utente con ID $id non trovato.");
    }
  }

  Future<void> updateUserField(int id, String fieldName, dynamic value) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update({fieldName: value});
    }
  }

  // --- CANCELLAZIONE (Corretto return type a Future<bool>) ---
  Future<bool> deleteUser(int id) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).delete();
      return true; // Ritorna true come si aspetta il ProfileService
    }
    return false;
  }

  // --- GESTIONE LISTE ---

  Future<void> addToArrayField(int id, String fieldName, dynamic item) async {
    final docId = await _findDocIdByIntId(id);
    if (docId == null) return;
    final doc = await _usersCollection.document(docId).get();
    List<dynamic> list = (doc.map[fieldName] as List<dynamic>?)?.toList() ?? [];
    list.add(item);
    await _usersCollection.document(docId).update({fieldName: list});
  }

  Future<void> removeFromArrayField(int id, String fieldName, dynamic item) async {
    final docId = await _findDocIdByIntId(id);
    if (docId == null) return;
    final doc = await _usersCollection.document(docId).get();
    List<dynamic> list = (doc.map[fieldName] as List<dynamic>?)?.toList() ?? [];
    final itemJson = jsonEncode(item);
    list.removeWhere((element) => jsonEncode(element) == itemJson);
    await _usersCollection.document(docId).update({fieldName: list});
  }

  // --- OTP ---

  Future<void> saveOtp(String telefono, String otp) async {
    await _phoneVerifications.document(telefono).set({
      'otp': otp,
      'telefono': telefono,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> verifyOtp(String telefono, String otp) async {
    final docRef = _phoneVerifications.document(telefono);
    if (!await docRef.exists) return false;
    final data = await docRef.get();
    if (data['otp'] == otp) {
      await docRef.delete();
      return true;
    }
    return false;
  }

  Future<void> markUserAsVerified(String identifier) async {
    // --- MODIFICA QUI ---
    // Rimuoviamo il tentativo di accesso diretto (document(identifier))
    // perché ora l'ID è un numero, mentre 'identifier' è email o telefono.

    // Cerchiamo direttamente l'utente tramite query
    var pages = await _usersCollection.where('email', isEqualTo: identifier).get();

    if (pages.isEmpty) {
      pages = await _usersCollection.where('telefono', isEqualTo: identifier).get();
    }

    if (pages.isNotEmpty) {
      await _usersCollection.document(pages.first.id).update({'isVerified': true, 'attivo': true});
    }
    // --------------------
  }
}