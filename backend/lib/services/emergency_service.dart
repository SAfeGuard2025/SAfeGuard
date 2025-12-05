import '../repositories/emergency_repository.dart';

class EmergencyService {
  final EmergencyRepository _repository = EmergencyRepository();

  /// Gestisce la richiesta di invio SOS.
  /// Esegue validazioni di business logic prima di salvare nel DB.
  Future<void> processSosRequest({
    required String userId,
    required String? email,
    required String? phone,
    required String type,
    required double lat,
    required double lng,
  }) async {

    // 1. Validazione GPS di base
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      throw ArgumentError("Coordinate GPS non valide: Lat $lat, Lng $lng");
    }

    // 2. Controllo ID Utente
    if (userId.isEmpty) {
      throw ArgumentError("ID Utente mancante.");
    }

    // 3. Normalizzazione Tipo Emergenza (Opzionale)
    // Se arriva un tipo sconosciuto, lo forziamo a "Generico" per pulizia dati
    const allowedTypes = ['Generico', 'Medico', 'Incendio', 'Polizia', 'Incidente'];
    final normalizedType = allowedTypes.contains(type) ? type : 'Generico';

    // 4. Salvataggio su DB
    try {
      await _repository.sendSos(
        userId: userId,
        email: email ?? "N/A",
        phone: phone ?? "N/A",
        type: normalizedType,
        lat: lat,
        lng: lng,
      );

      // (Opzionale) Qui potresti aggiungere:
      // - Invio Notifica Push ai soccorritori vicini (usando Firebase Cloud Messaging)
      // - Log dell'evento su un sistema di monitoring

    } catch (e) {
      print("Errore critico salvataggio SOS nel Service: $e");
      rethrow; // Rilancia l'errore al Controller per inviare risposta HTTP 500
    }
  }

  /// Annulla l'SOS attivo per un utente.
  Future<void> cancelSos(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError("ID Utente mancante per cancellazione.");
    }

    await _repository.deleteSos(userId);
  }

  /// Recupera tutte le emergenze attive.
  Future<List<Map<String, dynamic>>> getActiveEmergencies() async {
    return await _repository.getAllActiveEmergencies();
  }
}