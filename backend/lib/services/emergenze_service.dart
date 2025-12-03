// File: backend/lib/services/emergenze_service.dart

import '../repositories/user_repository.dart';
import 'notification_service.dart';

class EmergenzeService {
  final UserRepository _userRepository = UserRepository();
  final NotificationService _notificationService = NotificationService();

  // Raggio di pericolo per i cittadini (es. 5 km)
  static const double dangerRadiusKm = 5.0;

  //Gestisce il trigger di notifica dopo la ricezione dell'SOS.
  Future<void> triggerSOSNotification({
    required double lat,
    required double lng,
    required String sosId,
    required String type, // Es. "Incendio", "Terremoto"
    String? description,
    required int senderId,
  }) async {
    // GRUPPO A: I SOCCORRITORI (Ricevono TUTTO)
    final rescuerTokens = await _userRepository.findRescuerTokens();

    if (rescuerTokens.isNotEmpty) {
      await _notificationService.sendNotificationToTokens(
        rescuerTokens,
        "🚨 RICHIESTA INTERVENTO: $type",
        "Nuova segnalazione operativa. Posizione: $lat, $lng. Descrizione: ${description ?? 'Nessuna'}",
        {
          'sosId': sosId,
          'type': 'RESCUER_ALERT',
          'category': type,
          'lat': lat,
          'lng': lng,
        },
      );
      print("   -> 🚑 Notificati ${rescuerTokens.length} soccorritori.");
    } else {
      print("   -> Nessun soccorritore trovato.");
    }

    // GRUPPO B: I CITTADINI NELLE VICINANZE (Solo chi è a rischio)
    final citizenTokens = await _userRepository.findNearbyTokensReal(
      lat,
      lng,
      dangerRadiusKm,
    );

    if (citizenTokens.isNotEmpty) {
      await _notificationService.sendNotificationToTokens(
        citizenTokens,
        "⚠️ PERICOLO VICINO A TE",
        "È stato segnalato un $type a meno di ${dangerRadiusKm.toInt()}km dalla tua posizione. Mettiti al sicuro.",
        {
          'sosId': sosId,
          'type':
              'DANGER_ALERT', // Tipo diverso per far reagire l'app diversamente
          'category': type,
          'lat': lat,
          'lng': lng,
        },
      );
      print("   -> 📢 Allertati ${citizenTokens.length} cittadini a rischio.");
    } else {
      print(
        "   -> Nessun cittadino a rischio nel raggio di $dangerRadiusKm km.",
      );
    }
  }
}
