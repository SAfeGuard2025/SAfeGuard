// File: backend/lib/services/emergenze_service.dart

import '../repositories/user_repository.dart';
import 'notification_service.dart'; // Assumiamo sia già implementato
// Non c'è bisogno di GeoQueryService separato, la logica è nel repository.

class EmergenzeService {
  final UserRepository _userRepository = UserRepository();
  final NotificationService _notificationService = NotificationService();

  // Raggio di vicinanza SIMULATO
  static const double proximityRadiusKm = 10.0;

  /// ------------------------------------------------------------------
  /// AZIONE CRITICA: Gestisce il trigger di notifica dopo la ricezione dell'SOS.
  /// ------------------------------------------------------------------
  Future<void> triggerSOSNotification(double sosLat, double sosLng, String sosId) async {

    print('🚨 Trigger Notifiche SOS avviato per ID: $sosId');

    // 1. Target 1: Trova i Token dei Soccorritori (Query Reale)
    final soccorritoriTokens = await _userRepository.findRescuerTokens();
    print('   -> Trovati ${soccorritoriTokens.length} token Soccorritori.');

    // 2. Target 2: Trova i Token degli Utenti Nelle Vicinanze (Simulato)
    final nearbyUsersTokens = await _userRepository.findNearbyTokensSimulated(
        sosLat, sosLng, proximityRadiusKm
    );
    print('   -> Trovati ${nearbyUsersTokens.length} token Utenti Vicini (Simulato).');

    // 3. Unisci i Token (rimuove i duplicati, se un soccorritore è vicino)
    final List<String> allTokens = [...soccorritoriTokens, ...nearbyUsersTokens].toSet().toList();
    print('   -> Invio a un totale di ${allTokens.length} token unici.');

    // 4. Invia Notifiche (Chiama FCM)
    final payloadData = {
      'sosId': sosId,
      'latitude': sosLat.toString(),
      'longitude': sosLng.toString(),
      'eventType': 'SOS_ATTIVO',
    };

    if (allTokens.isNotEmpty) {
      await _notificationService.sendNotificationToTokens(
          allTokens,
          "🚨 NUOVA EMERGENZA SOS 🚨",
          "Richiesta di aiuto nelle vicinanze ($proximityRadiusKm km). Controllare la mappa operativa.",
          payloadData
      );
    }
  }
}