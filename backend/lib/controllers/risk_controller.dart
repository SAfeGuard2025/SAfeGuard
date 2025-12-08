import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;
import '../services/risk_service.dart';

// Controller responsabile della gestione di tutte le richieste API relative alla logica di rischio/AI.
// 1. Funge da PROXY: Inoltra i dati di emergenza al microservizio AI Python per l'analisi.
// 2. Data Access: Fornisce all'app mobile gli Hotspot calcolati, recuperandoli dal DB tramite il RiskService.
class RiskController {
  // 1. Inizializzazione del Service: Il Controller si occupa di creare l'istanza del Service.
  final RiskService _riskService = RiskService();

  // URL del microservizio AI Python
  final String _aiServiceUrl;

  /* Schema richiesta HTTP POST (Payload inviato al Microservizio AI Python)

  Il corpo della richiesta HTTP POST inviata dal frontend mobile
  deve essere un oggetto JSON contenente un array di 'reports'.

  Schema JSON atteso:

  {
      "reports": [
          {
              // ID univoco della segnalazione (necessario per la tracciabilità)
              "id": "123456",
              // Latitudine del report (valore decimale obbligatorio)
              "lat": 40.75899247,
              // Longitudine del report (valore decimale obbligatorio)
              "lon": 14.65552131,
              // Tipo di evento (stringa: es. "Fire", "Flood", "Medical", ecc.)
              "event_type": "Fire",
              // Gravità dell'evento da 1 (bassa) a 5 (alta) (intero obbligatorio)
              "severity": 5
          },
          // L'array 'reports' può contenere più report in una singola richiesta
          {
              "id": 789012
              "lat": 40.760000,
              "lon": 14.656000,
              "event_type": "Road_Accident",
              "severity": 3
          }
      ]
  }
  */

  RiskController(this._aiServiceUrl)
  {
    // Log utile per capire quale URL sta usando il server all'avvio
    if (_aiServiceUrl.contains('127.0.0.1')) {
      print('RiskController: Variabile AI_SERVICE_URL non impostata o locale. Utilizzo: $_aiServiceUrl');
    } else {
      print('RiskController: Utilizzo URL di produzione: $_aiServiceUrl');
    }
  }

  final Map<String, String> _headers = {'content-type': 'application/json'};

  // Handler per l'API: POST /api/risk/analyze.
  // Agisce come proxy: inoltra il payload al server Python e restituisce la sua risposta.
  Future<Response> handleRiskAnalysis(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _badRequest('Nessun dato inviato');

      final payload = jsonDecode(body);
      _printFormattedJsonLog(payload);

      //final Map<String, dynamic> payload = jsonDecode(body);
      print('📤 Dart invia dati al server AI...');

      if (body.length > 50) {
        print('DART PROXY: IN USCITA (SNIPPET): ${body.substring(0, 50)}...');
      } else {
        _printFormattedJsonLog(payload);
      }

      // Chiamata asincrona al microservizio Python
      final aiResponse = await http.post(
        Uri.parse(_aiServiceUrl),
        headers: _headers,
        body: body,
      );

      print('📥 Risposta ricevuta da Python: ${aiResponse.statusCode}');

      if (aiResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(aiResponse.body);

        // Log formattato per debug
        //_printFormattedJsonLog(data);

        final Map<String, dynamic> cleanResponse = _extractCleanReports(data);

        return Response.ok(jsonEncode(cleanResponse), headers: _headers);
      } else {
        // Errore generico dal microservizio (es. errore logica Python, eccezione, Pydantic fallito)
        print('Errore AI (${aiResponse.statusCode}): ${aiResponse.body}');
        return _internalServerError(
          'Errore dal servizio AI: ${aiResponse.body}',
        );
      }
    } catch (e) {
      print('Errore RiskController (Analisi AI): $e');
      return _internalServerError('Errore interno: $e');
    }
  }

  // Prende la risposta completa dell'AI e restituisce solo ciò che serve all'app.
  Map<String, dynamic> _extractCleanReports(Map<String, dynamic> aiData) {

    // 1. Isola i metadati per log interno
    final int historicalCount = aiData['historical_hotspots_count'] ?? 0;
    final int highRiskCount = aiData['high_risk_reports'] ?? 0;
    print('INFO AI: Hotspot storici usati: $historicalCount | Report ad alto rischio: $highRiskCount');

    // 2. Estrae la lista dei report analizzati
    final List<dynamic> rawReports = aiData['analyzed_reports'] ?? [];

    return {
      'success': true,
      'timestamp': DateTime.now().toIso8601String(),
      'results': rawReports, // Qui ci sono solo i report singoli con ID, score, ecc.
    };
  }

  // Handler per l'API: GET /api/risk/hotspots
  Future<Response> handleHotspotsRequest(Request request) async {
    try {
      // Delega al RiskService il recupero degli Hotspot
      final hotspotsList = await _riskService.getHotspots();

      final jsonList = hotspotsList.map((h) => h.toJson()).toList();

      return Response.ok(jsonEncode(jsonList), headers: _headers);
    } catch (e) {
      return _internalServerError('Impossibile recuperare gli Hotspots.');
    }
  }

  // Helper per costruire risposte HTTP 400 Bad Request.
  Response _badRequest(String message) {
    return Response.badRequest(
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }

  // Helper per costruire risposte HTTP 500 Internal Server Error.
  Response _internalServerError(String message) {
    return Response.internalServerError(
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }

  // Helper per stampare JSON lunghi nel terminale in modo leggibile.
  void _printFormattedJsonLog(dynamic data) {
    final jsonString = jsonEncode(data);
    print('----------------------------------------------------');
    print('DATA AI START');

    final pattern = RegExp('.{1,800}');
    pattern.allMatches(jsonString).forEach((match) => print(match.group(0)));

    print('DATA AI END');
    print('----------------------------------------------------');
  }
}
