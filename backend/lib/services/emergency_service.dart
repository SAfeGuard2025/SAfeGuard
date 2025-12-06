import '../repositories/emergency_repository.dart';

class EmergencyService {
  // Dipendenze: Repository per DB e Servizi Ausiliari
  final EmergencyRepository _repository = EmergencyRepository();

  // Gestione Invio SOS Completo
  // Valida i dati, salva nel DB e innesca le notifiche push.
  Future<void> processSosRequest({
    required String userId,
    required String? email,
    required String? phone,
    required String type,
    required double lat,
    required double lng,
  }) async {
    // Validazione Input (Coordinate e ID)
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      throw ArgumentError("Coordinate GPS non valide");
    }

    // Controllo ID Utente
    if (userId.isEmpty) {
      throw ArgumentError("ID Utente mancante");
    }

    // Normalizzazione Tipo Emergenza
    const allowedTypes = ['Generico', 'Medico', 'Incendio', 'Polizia', 'Incidente'];
    final normalizedType = allowedTypes.contains(type) ? type : 'Generico';

    // Salvataggio su DB
    try {
      // Scrittura su Database
      await _repository.sendSos(
        userId: userId,
        email: email ?? "N/A",
        phone: phone ?? "N/A",
        type: normalizedType,
        lat: lat,
        lng: lng,
      );


    } catch (e) {
      print("Errore critico Service SOS: $e");
      rethrow;
    }
  }


  // Annullamento SOS
  Future<void> cancelSos(String userId) async {
    if (userId.isEmpty) throw ArgumentError("ID Utente mancante");
    await _repository.deleteSos(userId);
  }

  // Live Tracking (Aggiornamento Posizione)
  Future<void> updateUserLocation(String userId, double lat, double lng) async {
    // Validazione rapida per evitare dati sporchi nel DB
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return;

    await _repository.updateLocation(userId, lat, lng);
  }

  // Recupero Lista Emergenze Attive
  Future<List<Map<String, dynamic>>> getActiveEmergencies() async {
    return await _repository.getAllActiveEmergencies();
  }
}