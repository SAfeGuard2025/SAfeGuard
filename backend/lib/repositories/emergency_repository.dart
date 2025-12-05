import 'package:firedart/firedart.dart';

class EmergencyRepository {
  // Riferimento alla collezione delle emergenze attive
  CollectionReference get _emergenciesCollection =>
      Firestore.instance.collection('active_emergencies');

  // Riferimento opzionale per lo storico (se vuoi salvare le emergenze chiuse)
  CollectionReference get _emergenciesHistory =>
      Firestore.instance.collection('emergencies_history');

  /// Crea o aggiorna una segnalazione di emergenza.
  /// Usa l'userId come chiave del documento (Document ID) per garantire
  /// che un utente possa avere solo una emergenza attiva alla volta.
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

    // Scrittura su Firestore (usando la sintassi di firedart)
    await _emergenciesCollection.document(userId).set(emergencyData);
  }

  /// Recupera tutte le emergenze attive.
  /// Utile per dashboard o per inviare la lista ai soccorritori.
  Future<List<Map<String, dynamic>>> getAllActiveEmergencies() async {
    final documents = await _emergenciesCollection.get();
    // Converte la lista di Document in lista di Map
    return documents.map((doc) => doc.map).toList();
  }

  /// Recupera una singola emergenza tramite ID utente.
  Future<Map<String, dynamic>?> getEmergencyByUserId(String userId) async {
    try {
      final doc = await _emergenciesCollection.document(userId).get();
      return doc.map;
    } catch (e) {
      return null; // Documento non trovato
    }
  }

  /// Elimina l'emergenza (Stop SOS).
  /// Prima di eliminare, sposta i dati nello storico.
  Future<void> deleteSos(String userId) async {
    final docRef = _emergenciesCollection.document(userId);

    // Controlla se esiste prima di provare a cancellare
    if (await docRef.exists) {
      // 1. (Opzionale) Leggi i dati per archiviarli
      final data = await docRef.get();

      // 2. (Opzionale) Salva nello storico con un ID univoco basato sul tempo
      final historyId = "${userId}_${DateTime.now().millisecondsSinceEpoch}";
      var historyData = Map<String, dynamic>.from(data.map);
      historyData['closed_at'] = DateTime.now().toIso8601String();
      historyData['final_status'] = 'resolved'; // o 'cancelled'

      await _emergenciesHistory.document(historyId).set(historyData);

      // 3. Cancella dalla collezione attiva
      await docRef.delete();
    }
  }
}