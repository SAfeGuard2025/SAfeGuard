import '../repositories/emergency_repository.dart';
import '../repositories/user_repository.dart'; // 1. Importa UserRepository
import 'notifiche_service.dart';            // 2. Importa NotificationService
import 'dart:async';

class EmergencyService {
  final EmergencyRepository _repository = EmergencyRepository();

  // Inietta le dipendenze per le notifiche
  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepository = UserRepository();

  // Definisci il raggio di pericolo
  static const double dangerRadiusKm = 5.0;

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

      // 2. 🚨 ATTIVAZIONE NOTIFICHE PUSH 🚨
      await _triggerSOSNotification(
        userId: userId,
        lat: lat,
        lng: lng,
        type: normalizedType,
        // Altri dati necessari per la notifica (es. l'ID specifico dell'SOS se generato qui)
      );

    } catch (e) {
      print("Errore critico salvataggio SOS nel Service: $e");
      rethrow; // Rilancia l'errore al Controller per inviare risposta HTTP 500
    }
  }

  Future<void> _triggerSOSNotification({
    required String userId,
    required double lat,
    required double lng,
    required String type,
    // Aggiungi qui gli altri dati necessari per l'invio (es. sosId, description)
  }) async {
    final String sosId = userId;

    // Eseguiamo gli invii in parallelo per velocità
    await Future.wait([

      // A. 🧑‍🚒 Notifica per i Soccorritori
      (() async {
        final rescuerTokens = await _userRepository.findRescuerTokens();
        if (rescuerTokens.isNotEmpty) {
          print('Trovati ${rescuerTokens.length} soccorritori. Invio alert...');
          await _notificationService.sendNotificationToTokens(
            rescuerTokens,
            "🚨 RICHIESTA INTERVENTO: $type",
            "Nuova emergenza rilevata. Posizione: $lat, $lng.",
            {
              'sosId': sosId,
              'type': 'RESCUER_ALERT',
              'category': type,
              'lat': lat.toString(),
              'lng': lng.toString(),
            },
          );
        }
      })(),

      // B. ⚠️ Notifica per i Cittadini Vicini
      (() async {
        final citizenTokens = await _userRepository.findNearbyTokensReal(
          lat,
          lng,
          dangerRadiusKm,
        );
        if (citizenTokens.isNotEmpty) {
          print('Trovati ${citizenTokens.length} cittadini nel raggio di $dangerRadiusKm km. Invio alert...');
          await _notificationService.sendNotificationToTokens(
            citizenTokens,
            "⚠️ PERICOLO VICINO A TE",
            "È stato segnalato un $type a meno di ${dangerRadiusKm.toInt()}km dalla tua posizione.",
            {
              'sosId': sosId,
              'type': 'DANGER_ALERT',
              'category': type,
              'lat': lat.toString(),
              'lng': lng.toString(),
            },
          );
        }
      })(),
    ]);
    print('Catena notifiche SOS completata per $sosId.');
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