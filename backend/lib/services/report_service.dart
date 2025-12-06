import '../repositories/report_repository.dart';
import '../repositories/user_repository.dart';
import 'notification_service.dart';

class ReportService {
  // Dipendenze: Repository per il DB e Service per le notifiche
  final ReportRepository _reportRepository = ReportRepository();
  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepo = UserRepository();

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
    await _reportRepository.createReport(reportData);

    // Passa il senderId per escluderlo
    if (isSenderRescuer) {
      await _notifyCitizens(type, description, senderId);
    } else {
      await _notifyRescuers(type, description, senderId);
    }
  }

  //Recupera tutti i report attivi dal database.
  Future<List<Map<String, dynamic>>> getReports() async {
    return await _reportRepository.getAllReports();
  }

  //Chiude un report
  Future<void> closeReport(String id) async {
    await _reportRepository.deleteReport(id);
  }

  // Notifica i Soccorritori in seguito a un report da un Cittadino.
  Future<void> _notifyRescuers(String type, String? description, int senderId) async {
    try {
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

  // Notifica i Cittadini in seguito a un report da un Soccorritore.
  Future<void> _notifyCitizens(String type, String? description, int senderId) async {
    try {
      List<String> tokens = await _userRepo.getCitizenTokens(excludedId: senderId);
      print("Trovati ${tokens.length} cittadini da allertare.");

      if (tokens.isNotEmpty) {
        await _notificationService.sendBroadcast(
          title: "AVVISO PROTEZIONE CIVILE: $type",
          body: description ?? "Comunicazione ufficiale di emergenza.",
          tokens: tokens,
        );
      }
    } catch (e) {
      print("Errore notifica cittadini: $e");
    }
  }
}