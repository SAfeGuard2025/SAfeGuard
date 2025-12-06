import '../repositories/emergency_repository.dart';
import '../repositories/user_repository.dart';
import 'notifiche_service.dart';
import 'dart:async';

class EmergencyService {
  // Dipendenze: Repository per DB e Servizi Ausiliari
  final EmergencyRepository _repository = EmergencyRepository();

  // Inietta le dipendenze per le notifiche
  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepository = UserRepository();

  // Configurazione: Raggio per l'invio notifiche di pericolo ai cittadini
  static const double dangerRadiusKm = 5.0;

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

      // Invio Notifiche Push (Async)
      await _triggerSOSNotification(
        userId: userId,
        lat: lat,
        lng: lng,
        type: normalizedType,
      );

    } catch (e) {
      print("Errore critico Service SOS: $e");
      rethrow;
    }
  }

  // Logica Notifiche Push (Soccorritori + Cittadini)
  Future<void> _triggerSOSNotification({
    required String userId,
    required double lat,
    required double lng,
    required String type,
  }) async {
    final String sosId = userId;

    // Eseguiamo in parallelo per non bloccare l'esecuzione
    await Future.wait([
      // Notifica ai Soccorritori (Tutti)
      (() async {
        final rescuerTokens = await _userRepository.findRescuerTokens();
        if (rescuerTokens.isNotEmpty) {
          await _notificationService.sendNotificationToTokens(
            rescuerTokens,
            "🚨 RICHIESTA INTERVENTO: $type",
            "Nuova emergenza rilevata. Posizione: $lat, $lng.",
            {'sosId': sosId, 'type': 'RESCUER_ALERT', 'lat': '$lat', 'lng': '$lng'},
          );
        }
      })(),

      // Notifica ai Cittadini (Solo vicini)
      (() async {
        final citizenTokens = await _userRepository.findNearbyTokensReal(
          lat, lng, dangerRadiusKm,
        );
        if (citizenTokens.isNotEmpty) {
          await _notificationService.sendNotificationToTokens(
            citizenTokens,
            "⚠️ PERICOLO VICINO A TE",
            "Segnalato $type a meno di ${dangerRadiusKm.toInt()}km.",
            {'sosId': sosId, 'type': 'DANGER_ALERT', 'lat': '$lat', 'lng': '$lng'},
          );
        }
      })(),
    ]);
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