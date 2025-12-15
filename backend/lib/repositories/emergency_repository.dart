import 'package:firedart/firedart.dart';

class EmergencyRepository {
  // Collezione per le emergenze attualmente in corso
  CollectionReference get _emergenciesCollection =>
      Firestore.instance.collection('active_emergencies');

  // Collezione per lo storico delle emergenze chiuse
  CollectionReference get _emergenciesHistory =>
      Firestore.instance.collection('emergencies_history');

  // Crea o sovrascrive una richiesta di soccorso per un utente
  // Usa l'userId come chiave del documento per garantire
  // che un utente possa avere solo una emergenza attiva alla volta.
  Future<void> sendSos({
    required String userId,
    required String? email,
    required String? phone,
    required String type,
    required double lat,
    required double lng,
  }) async {
    final emergencyData = {
      'user_id': userId,
      'email': email ?? "N/A",
      'phone': phone ?? "N/A",
      'type': type,
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'active',
    };

    await _emergenciesCollection.document(userId).set(emergencyData);
  }

  // Recupera la lista di tutte le emergenze attive
  Future<List<Map<String, dynamic>>> getAllActiveEmergencies() async {
    final documents = await _emergenciesCollection.get();
    // Converte la lista di Document in lista di Map
    return documents.map((doc) => doc.map).toList();
  }

  // Cerca un'emergenza specifica tramite ID utente
  Future<Map<String, dynamic>?> getEmergencyByUserId(String userId) async {
    try {
      final doc = await _emergenciesCollection.document(userId).get();
      return doc.map;
    } catch (e) {
      return null;
    }
  }

  // Archivia l'emergenza nello storico e la rimuove dalle attive
  Future<void> deleteSos(String userId) async {
    final docRef = _emergenciesCollection.document(userId);

    // Controlla se esiste prima di provare a cancellare
    if (await docRef.exists) {
      // 1. Recupero emergenza
      final data = await docRef.get();

      // 2. Salva nello storico con un ID univoco basato sul tempo
      final historyId = "${userId}_${DateTime.now().millisecondsSinceEpoch}";

      var historyData = Map<String, dynamic>.from(data.map);
      historyData['closed_at'] = DateTime.now().toIso8601String();
      historyData['final_status'] = 'resolved';

      await _emergenciesHistory.document(historyId).set(historyData);

      // 3. Cancellazione
      await docRef.delete();
    }
  }

  // Aggiorna solo le coordinate GPS
  Future<void> updateLocation(String userId, double lat, double lng) async {
    final docRef = _emergenciesCollection.document(userId);

    if (await docRef.exists) {
      await docRef.update({'lat': lat, 'lng': lng});
    }
  }
}
