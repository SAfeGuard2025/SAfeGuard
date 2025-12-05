import 'package:firedart/firedart.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/soccorritore.dart';
import 'package:data_models/utente_generico.dart';
import 'dart:math';
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

  // Salva un nuovo utente nel DB, genera l'ID interno e lo usa come DocId
  Future<UtenteGenerico> saveUser(UtenteGenerico newUser) async {
    final int newId = DateTime.now().millisecondsSinceEpoch;
    final userData = newUser.toJson();
    userData['id'] = newId;

    // Usa l'ID numerico come chiave stringa per il documento (DocId)
    final String docId = newId.toString();

    await _usersCollection.document(docId).set(userData);

    // Ritorna l'oggetto UtenteGenerico con i dati aggiornati e l'ID
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
  Future<bool> deleteUser(int id) async {
    final docId = await _findDocIdByIntId(id);
    if (docId != null) {
      await _usersCollection.document(docId).delete();
      return true;
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

  // 🆕 1. SALVATAGGIO/AGGIORNAMENTO TOKEN FCM
  Future<void> updateUserFCMToken(int userId, String fcmToken) async {
    final docId = await _findDocIdByIntId(userId); // Usa la tua utility esistente
    if (docId != null) {
      await _usersCollection.document(docId).update({
        'fcmToken': fcmToken,
        'token_updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      throw Exception("Utente con ID $userId non trovato per aggiornamento token.");
    }
  }

  // 🆕 2. RECUPERO TOKEN SOCCOTRITORI (Chiamato da EmergenzeService)
  Future<List<String>> findRescuerTokens() async {
    // Presupposto: gli utenti soccorritori hanno un campo 'ruolo'/'isSoccorritore' corretto
    final snapshot = await _usersCollection.where('ruolo', isEqualTo: 'Soccorritore').get();
    // Oppure: .where('isSoccorritore', isEqualTo: true) a seconda del tuo schema

    final tokens = snapshot
        .map((doc) => doc.map['fcmToken'] as String?)
        .where((token) => token != null && token!.isNotEmpty) // Controlla anche che non sia vuoto
        .cast<String>()
        .toList();
    return tokens;
  }

  // 🆕 3. RECUPERO CITTADINI VICINI (Chiamato da EmergenzeService)
  Future<List<String>> findNearbyTokensReal(
      double lat,
      double lng,
      double radiusKm,
      ) async {
    final snapshot = await _usersCollection.get();

    final List<String> nearbyTokens = [];
    for (var doc in snapshot) {
      final userLat = (doc.map['lat'] as num?)?.toDouble();
      final userLng = (doc.map['lng'] as num?)?.toDouble();
      final token = doc.map['fcmToken'] as String?;

      // Filtra solo gli utenti cittadini che hanno una posizione salvata e un token valido
      if (userLat != null && userLng != null && token != null && token.isNotEmpty && doc.map['ruolo'] == 'Cittadino') {
        final distance = _calculateDistance(lat, lng, userLat, userLng);

        if (distance <= radiusKm) {
          nearbyTokens.add(token);
        }
      }
    }
    return nearbyTokens;
  }

  // 🆕 4. FUNZIONE DI CALCOLO DISTANZA PRECISA (Haversine)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const p = 0.017453292519943295; // Pi greco / 180
    const R = 6371; // Raggio medio della Terra in km

    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lng2 - lng1) * p)) /
            2;

    return R * 2 * asin(sqrt(a)); // Distanza in Km
  }
}


