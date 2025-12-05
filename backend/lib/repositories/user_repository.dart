import 'package:firedart/firedart.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';
import 'package:data_models/utente_generico.dart';
import 'dart:convert';

class UserRepository {
  // Riferimenti alle collezioni usate nel database.
  CollectionReference get _usersCollection =>
      Firestore.instance.collection('users');
  CollectionReference get _phoneVerifications =>
      Firestore.instance.collection('phone_verifications');

  // Cerca un utente nella collezione 'users' tramite il campo 'email'
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final pages = await _usersCollection
        .where('email', isEqualTo: email.toLowerCase())
        .get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  // Cerca un utente nella collezione 'users' tramite il campo 'telefono'
  Future<Map<String, dynamic>?> findUserByPhone(String phone) async {
    final pages = await _usersCollection
        .where('telefono', isEqualTo: phone)
        .get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  // Cerca un utente nella collezione 'users' tramite il campo 'id'
  Future<Map<String, dynamic>?> findUserById(int id) async {
    final pages = await _usersCollection.where('id', isEqualTo: id).get();
    if (pages.isEmpty) return null;
    return pages.first.map;
  }

  // Salva un nuovo utente o aggiorna uno esistente
  Future<UtenteGenerico> saveUser(UtenteGenerico newUser) async {
    // Se l'utente ha già un ID (es. registrazione non verificata), usalo.
    // Altrimenti ne genera uno nuovo.
    int idToUse = newUser.id != null && newUser.id! > 0
        ? newUser.id!
        : DateTime.now().millisecondsSinceEpoch;

    final userData = newUser.toJson();
    userData['id'] = idToUse; // Assicura che il JSON abbia l'ID corretto

    // Usa l'ID come chiave stringa per il documento
    final String docId = idToUse.toString();

    // .set(userData) sovrascriverà il documento esistente se l'ID è lo stesso,
    // invece di crearne uno nuovo.
    await _usersCollection.document(docId).set(userData);

    // Ritorna l'oggetto aggiornato
    if (newUser is Soccorritore || (userData['isSoccorritore'] == true)) {
      return Soccorritore.fromJson(userData);
    } else {
      return Utente.fromJson(userData);
    }
  }

  // Crea utente usato specificamente per flussi esterni (Google/Apple Login)
  Future<Map<String, dynamic>> createUser(
    Map<String, dynamic> userData, {
    String collection = 'users',
  }) async {
    // Assicura che l'ID interno sia presente
    if (userData['id'] == null || userData['id'] == 0) {
      userData['id'] = DateTime.now().millisecondsSinceEpoch;
    }

    // Usa l'ID generato come DocId
    final String docId = userData['id'].toString();

    // Salvataggio nella collezione specificata
    await Firestore.instance
        .collection(collection)
        .document(docId)
        .set(userData);

    return userData;
  }

  // Utility per trovare il DocId stringa di Firestore a partire dall'ID int interno
  Future<String?> _findDocIdByIntId(int id) async {
    final docId = id.toString();

    try {
      await _usersCollection.document(docId).get();
      return docId;
    } catch (e) {
      return null; // DocId non trovato
    }
  }

  // Aggiorna genericamente più campi di un utente
  Future<void> updateUserGeneric(int id, Map<String, dynamic> updates) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update(updates);
    } else {
      throw Exception("Utente con ID $id non trovato.");
    }
  }

  // Aggiorna un singolo campo di un utente
  Future<void> updateUserField(int id, String fieldName, dynamic value) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).update({fieldName: value});
    }
  }

  // Elimina l'utente dal database tramite il suo ID interno
  // Elimina l'utente dal database archiviandolo prima in 'deleted_users'
  Future<bool> deleteUser(int id) async {
    final docId = await _findDocIdByIntId(id);

    if (docId != null) {
      try {
        // 1. Recupero i dati attuali dell'utente prima di eliminarlo
        final docSnapshot = await _usersCollection.document(docId).get();
        final userData = docSnapshot.map;

        // 2. Preparo i dati per l'archiviazione
        // Creo una copia modificabile della mappa
        final archiveData = Map<String, dynamic>.from(userData);

        // Aggiungo un timestamp per sapere quando è avvenuta l'eliminazione
        archiveData['deletedAt'] = DateTime.now().toIso8601String();

        // 3. Salvo nella collezione 'deleted_users'
        // Uso .add() invece di .set() per generare un ID documento casuale.
        // Questo permette di avere più record per lo stesso utente se si registra
        // e si cancella più volte (duplicati ammessi).
        await Firestore.instance.collection('deleted_users').add(archiveData);

        // 4. Elimino il documento dalla collezione principale 'users'
        await _usersCollection.document(docId).delete();

        return true;
      } catch (e) {
        print("Errore durante l'archiviazione o eliminazione utente: $e");
        // Se fallisce l'archiviazione, decidiamo di non eliminare l'utente per sicurezza,
        return false;
      }
    }
    return false;
  }

  // Aggiunge un elemento a un campo array di un utente
  Future<void> addToArrayField(int id, String fieldName, dynamic item) async {
    final docId = await _findDocIdByIntId(id);
    if (docId == null) return;

    final doc = await _usersCollection.document(docId).get();
    List<dynamic> list = (doc.map[fieldName] as List<dynamic>?)?.toList() ?? [];
    list.add(item);
    await _usersCollection.document(docId).update({fieldName: list});
  }

  // Rimuove un elemento specifico da un campo array
  Future<void> removeFromArrayField(
    int id,
    String fieldName,
    dynamic item,
  ) async {
    final docId = await _findDocIdByIntId(id);
    if (docId == null) return;

    final doc = await _usersCollection.document(docId).get();
    List<dynamic> list = (doc.map[fieldName] as List<dynamic>?)?.toList() ?? [];

    // Serializza per confrontare oggetti complessi all'interno della lista
    final itemJson = jsonEncode(item);
    list.removeWhere((element) => jsonEncode(element) == itemJson);

    await _usersCollection.document(docId).update({fieldName: list});
  }

  // Salva il codice OTP nella collezione 'phone_verifications' usando il telefono come DocId
  Future<void> saveOtp(String telefono, String otp) async {
    await _phoneVerifications.document(telefono).set({
      'otp': otp,
      'telefono': telefono,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Verifica che l'OTP fornito corrisponda a quello nel database e lo elimina in caso di successo
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

  // Trova un utente tramite email o telefono e lo marca come verificato/attivo
  Future<void> markUserAsVerified(String identifier) async {
    // Normalizza l'input
    final idLower = identifier.toLowerCase();

    // Cerca per email o telefono
    var pages = await _usersCollection.where('email', isEqualTo: idLower).get();

    if (pages.isEmpty) {
      pages = await _usersCollection
          .where('telefono', isEqualTo: identifier)
          .get();
    }

    //Se l'utente è stato trovato, aggiorna i campi di stato
    if (pages.isNotEmpty) {
      await _usersCollection.document(pages.first.id).update({
        'isVerified': true,
        'attivo': true,
      });
    }
  }
}
