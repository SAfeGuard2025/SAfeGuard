import '../repositories/emergency_repository.dart';
import '../repositories/user_repository.dart';
import 'notification_service.dart';
import 'dart:core';

class EmergencyService {
  // Dichiarazione delle dipendenze come campi finali
  final EmergencyRepository _repository;
  final NotificationService _notificationService;
  final UserRepository _userRepo;

  // Costruttore che accetta le dipendenze (Dependency Injection)
  EmergencyService({
    EmergencyRepository? repository,
    NotificationService? notificationService,
    UserRepository? userRepo,
  }) : _repository = repository ?? EmergencyRepository(), // Fallback
       _notificationService = notificationService ?? NotificationService(),
       _userRepo = userRepo ?? UserRepository();

  // Gestione Invio SOS Completo
  Future<void> processSosRequest({
    required String userId,
    required String? email,
    required String? phone,
    required String type,
    required double lat,
    required double lng,
  }) async {
    // 1. Validazione Generale Input
    if (userId.isEmpty) throw ArgumentError("ID Utente mancante");

    // Validazione globale GPS (già presente)
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      throw ArgumentError("Coordinate GPS non valide");
    }

    // Validazione Coordinate Salerno (Test 6)
    // Coordinate approssimative per la zona di Salerno, Italia (ITA)
    const double salernoLatMin = 40.60;
    const double salernoLatMax = 40.80;
    const double salernoLngMin = 14.70;
    const double salernoLngMax = 14.90;

    if (lat < salernoLatMin ||
        lat > salernoLatMax ||
        lng < salernoLngMin ||
        lng > salernoLngMax) {
      throw ArgumentError("Coordinate fuori dall'area operativa di Salerno.");
    }

    // Validazione Telefono (+39) (Test 7)
    // Vincolo: Il numero di telefono deve iniziare con +39 prefisso italiano se fornito
    if (phone != null && phone.isNotEmpty && !phone.startsWith('+39')) {
      throw ArgumentError(
        "Formato telefono non valido. Deve iniziare con +39.",
      );
    }

    // Validazione Email (Formato) (Test 8)
    // Vincolo: L'email deve essere in un formato valido (contenente @ e ."dominio") se fornita
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (email != null && email.isNotEmpty && !emailRegex.hasMatch(email)) {
      throw ArgumentError("Formato email non valido.");
    }

    // 2. Normalizzazione del Tipo SOS
    const allowedTypes = [
      'Generico',
      'Medico',
      'Incendio',
      'Polizia',
      'Incidente',
      'SOS Generico',
    ];
    final normalizedType = allowedTypes.contains(type) ? type : 'Generico';

    try {
      // 3. Scrittura su Database
      await _repository.sendSos(
        userId: userId,
        email: email ?? "N/A",
        phone: phone ?? "N/A",
        type: normalizedType,
        lat: lat,
        lng: lng,
      );

      // 4. Notifica
      await _notifyRescuers(normalizedType, userId);
    } catch (e) {
      print("Errore critico Service SOS: $e");
      rethrow;
    }
  }

  // Invio notifica ai soccorritori
  Future<void> _notifyRescuers(String type, String senderId) async {
    try {
      // Recupera i token di tutti i soccorritori
      final int? senderIdInt = int.tryParse(senderId);

      List<String> tokens = await _userRepo.getRescuerTokens(
        excludedId: senderIdInt,
      );

      if (tokens.isNotEmpty) {
        print("Invio notifica SOS a ${tokens.length} soccorritori...");
        await _notificationService.sendBroadcast(
          title: "SOS ATTIVO: $type",
          body:
              "Richiesta di soccorso urgente! Clicca per vedere la posizione.",
          tokens: tokens,
          type:
              'emergency_alert', // Questo triggera la navigazione nel frontend
        );
      } else {
        print("⚠Nessun soccorritore disponibile per la notifica.");
      }
    } catch (e) {
      print("Errore invio notifica SOS: $e");
    }
  }

  // Annullamento SOS
  Future<void> cancelSos(String userId) async {
    if (userId.isEmpty) throw ArgumentError("ID Utente mancante");
    await _repository.deleteSos(userId);
  }

  // Aggiornamento posizione in tempo reale
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
