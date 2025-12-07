import '../repositories/emergency_repository.dart';
import '../repositories/user_repository.dart';
import 'notification_service.dart';

class EmergencyService {
  final EmergencyRepository _repository = EmergencyRepository();
  final NotificationService _notificationService = NotificationService(); // Istanza
  final UserRepository _userRepo = UserRepository(); // Istanza per i token

  // Gestione Invio SOS Completo
  Future<void> processSosRequest({
    required String userId,
    required String? email,
    required String? phone,
    required String type,
    required double lat,
    required double lng,
  }) async {
    // ... (Validazioni esistenti) ...
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      throw ArgumentError("Coordinate GPS non valide");
    }
    if (userId.isEmpty) throw ArgumentError("ID Utente mancante");

    const allowedTypes = ['Generico', 'Medico', 'Incendio', 'Polizia', 'Incidente', 'SOS Generico'];
    final normalizedType = allowedTypes.contains(type) ? type : 'Generico';

    try {
      // 1. Scrittura su Database
      await _repository.sendSos(
        userId: userId,
        email: email ?? "N/A",
        phone: phone ?? "N/A",
        type: normalizedType,
        lat: lat,
        lng: lng,
      );

      // 2. INVIO NOTIFICA AI SOCCORRITORI [NUOVO]
      await _notifyRescuers(normalizedType, userId);

    } catch (e) {
      print("Errore critico Service SOS: $e");
      rethrow;
    }
  }

  // Metodo privato per notificare i soccorritori
  Future<void> _notifyRescuers(String type, String senderId) async {
    try {
      // Recupera i token di TUTTI i soccorritori (escluso chi invia, per sicurezza)
      // Nota: Convertiamo senderId in int se necessario o lo passiamo come stringa
      // Assumendo che senderId sia una stringa numerica dal DB
      final int? senderIdInt = int.tryParse(senderId);

      List<String> tokens = await _userRepo.getRescuerTokens(excludedId: senderIdInt);

      if (tokens.isNotEmpty) {
        print("🚑 Invio notifica SOS a ${tokens.length} soccorritori...");
        await _notificationService.sendBroadcast(
          title: "🆘 SOS ATTIVO: $type",
          body: "Richiesta di soccorso urgente! Clicca per vedere la posizione.",
          tokens: tokens,
          type: 'emergency_alert', // Questo triggera la navigazione nel frontend
        );
      } else {
        print("⚠️ Nessun soccorritore disponibile per la notifica.");
      }
    } catch (e) {
      print("❌ Errore invio notifica SOS: $e");
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