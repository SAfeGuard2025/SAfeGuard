import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import '../repositories/report_repository.dart';
import '../repositories/user_repository.dart';
import 'notification_service.dart';

class ReportService {
  // Dipendenze rese 'final' ma non inizializzate subito
  final ReportRepository _reportRepository;
  final NotificationService _notificationService;
  final UserRepository _userRepo;
  final http.Client _httpClient; // Aggiunto client HTTP iniettabile

  // Costruttore con Dependency Injection
  // Se i parametri non vengono passati (codice di produzione), usa le istanze reali.
  // Se vengono passati (test), usa i Mock.
  ReportService({
    ReportRepository? reportRepository,
    NotificationService? notificationService,
    UserRepository? userRepo,
    http.Client? httpClient,
  }) : _reportRepository = reportRepository ?? ReportRepository(),
       _notificationService = notificationService ?? NotificationService(),
       _userRepo = userRepo ?? UserRepository(),
       _httpClient = httpClient ?? http.Client();

  static final _env = DotEnv(includePlatformEnvironment: true)..load();

  String get _aiServiceUrl {
    String url =
        _env['AI_SERVICE_URL'] ??
        'https://moduloai.onrender.com/api/v1/analyze';

    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }

  Future<void> createReport({
    required int senderId,
    required bool isSenderRescuer,
    required String type,
    String? description,
    double? lat,
    double? lng,
    required int severity,
  }) async {
    if (description == null || description.trim().isEmpty) {
      print("Descrizione mancante. Operazione annullata.");
      return;
    }

    final String customId = DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Definisce i dati per active_emergencies
    final reportData = {
      'id': customId,
      'rescuer_id': senderId,
      'type': type,
      'description': description,
      'status': 'active',
      'lat': lat,
      'lng': lng,
      'severity': severity,
      'is_rescuer_report': isSenderRescuer,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 2. Salva in 'active_emergencies'
    print("📝 [START] Creazione report attivo: $customId");
    await _reportRepository.createReport(reportData, customId);

    // 3. Avvia Analisi AI
    // Passiamo i dati puliti. I risultati AI verranno uniti dopo in analyzed_reports.
    _analyzeAndArchiveReport(customId, reportData);

    // 4. Invia Notifiche
    if (isSenderRescuer) {
      await _notifyCitizens(type, description, senderId);
    } else {
      await _notifyRescuers(type, description, senderId);
    }
  }

  //Chiama AI -> Unisce i dati -> Salva SOLO in analyzed_reports
  Future<void> _analyzeAndArchiveReport(
    String reportId,
    Map<String, dynamic> originalData,
  ) async {
    try {
      final url = _aiServiceUrl;
      print("🤖 [AI] Invio report $reportId a: $url");

      final payload = {
        "reports": [
          {
            "id": reportId,
            "lat": originalData['lat'],
            "lon": originalData['lng'],
            "event_type": originalData['type'],
            "severity": originalData['severity'],
            "timestamp": originalData['timestamp'],
          },
        ],
      };

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analyzedList = data['analyzed_reports'] as List;

        if (analyzedList.isNotEmpty) {
          final analysis = analyzedList.first;

          // 1. Estrai i risultati AI
          final Map<String, dynamic> aiResults = {
            'risk_score': analysis['risk_score'],
            'risk_level': analysis['risk_level'],
            'hotspot_match': analysis['hotspot_match'] ?? false,
            'ai_processed_at': DateTime.now().toIso8601String(),
          };

          // 2. FUSIONE: Dati Originali + Dati AI
          final Map<String, dynamic> fullArchiveRecord = Map.from(originalData);
          fullArchiveRecord.addAll(aiResults);

          // 3. SALVATAGGIO: Scrive SOLO in analyzed_reports
          print("💾 [DB] Salvataggio in Analyzed Reports...");
          await _reportRepository.createAnalyzedReport(fullArchiveRecord);

          print(
            "✅ [AI] Processo completato: Attivo (Pulito) + Analizzato (Ricco) salvati.",
          );
        } else {
          print("⚠️ [AI] Risposta vuota dal servizio AI.");
        }
      } else {
        print("⚠️ [AI] Errore HTTP: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ [AI] Eccezione durante analisi/archiviazione: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    return await _reportRepository.getAllReports();
  }

  Future<void> closeReport(String id) async {
    await _reportRepository.deleteReport(id);
  }

  Future<void> _notifyRescuers(
    String type,
    String? description,
    int senderId,
  ) async {
    try {
      List<String> tokens = await _userRepo.getRescuerTokens(
        excludedId: senderId,
      );
      if (tokens.isNotEmpty) {
        await _notificationService.sendBroadcast(
          title: "ALLERTA CITTADINO: $type",
          body:
              description ?? "Richiesta di intervento inviata da un cittadino.",
          tokens: tokens,
          type: 'citizen_report',
        );
      }
    } catch (e) {
      print("Errore notifica soccorritori: $e");
    }
  }

  Future<void> _notifyCitizens(
    String type,
    String? description,
    int senderId,
  ) async {
    try {
      List<String> tokens = await _userRepo.getCitizenTokens(
        excludedId: senderId,
      );
      if (tokens.isNotEmpty) {
        await _notificationService.sendBroadcast(
          title: "AVVISO PROTEZIONE CIVILE: $type",
          body: description ?? "Comunicazione ufficiale di emergenza.",
          tokens: tokens,
          type: 'emergency_alert',
        );
      }
    } catch (e) {
      print("Errore notifica cittadini: $e");
    }
  }
}
