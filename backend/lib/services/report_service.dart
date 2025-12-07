import '../repositories/report_repository.dart';
import '../repositories/user_repository.dart';
import 'notification_service.dart';

class ReportService {
  final ReportRepository _repository = ReportRepository();
  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepo = UserRepository(); // Corretto riferimento

  Future<void> createReport({
    required int senderId,
    required bool isSenderRescuer,
    required String type,
    String? description,
    double? lat,
    double? lng,
  }) async {
    final reportData = {
      'rescuer_id': senderId,
      'type': type,
      'description': description ?? '',
      'status': 'active',
      'lat': lat,
      'lng': lng,
      'is_rescuer_report': isSenderRescuer,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 1. Salva su DB
    await _repository.createReport(reportData);

    // NOTIFICHE - Passiamo il senderId per escluderlo
    if (isSenderRescuer) {
      await _notifyCitizens(type, description, senderId); // <--- Passa ID
    } else {
      await _notifyRescuers(type, description, senderId); // <--- Passa ID
    }
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    return await _repository.getAllReports();
  }

  Future<void> closeReport(String id) async {
    await _repository.deleteReport(id);
  }

// Aggiungi parametro senderId
  Future<void> _notifyRescuers(String type, String? description, int senderId) async {
    try {
      // Passa excludedId al repository
      List<String> tokens = await _userRepo.getRescuerTokens(excludedId: senderId);

      if (tokens.isNotEmpty) {
        await _notificationService.sendBroadcast(
          title: "ALLERTA CITTADINO: $type",
          body: description ?? "Richiesta di intervento inviata da un cittadino.",
          tokens: tokens,
        );
      }
    } catch (e) {
      print("Errore notifica soccorritori: $e");
    }
  }

  // Aggiungi parametro senderId
  Future<void> _notifyCitizens(String type, String? description, int senderId) async {
    try {
      // Passa excludedId al repository
      List<String> tokens = await _userRepo.getCitizenTokens(excludedId: senderId);
      print("Trovati ${tokens.length} cittadini da allertare (mittente escluso).");

      if (tokens.isNotEmpty) {
        await _notificationService.sendBroadcast(
          title: "⚠️ AVVISO PROTEZIONE CIVILE: $type",
          body: description ?? "Comunicazione ufficiale di emergenza.",
          tokens: tokens,
        );
      }
    } catch (e) {
      print("Errore notifica cittadini: $e");
    }
  }
}