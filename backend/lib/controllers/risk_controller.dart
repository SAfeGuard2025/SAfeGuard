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
  final String _aiServiceUrl = 'http://127.0.0.1:8000/api/v1/analyze';

  final Map<String, String> _headers = {'content-type': 'application/json'};

  // Handler per l'API: POST /api/risk/analyze.
  // Agisce come proxy: inoltra il payload al server Python e restituisce la sua risposta.
  Future<Response> handleRiskAnalysis(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _badRequest('Nessun dato inviato');

      final Map<String, dynamic> payload = jsonDecode(body);
      print('📤 Dart invia dati al server AI...');

      // Chiamata asincrona al microservizio Python
      final aiResponse = await http.post(
        Uri.parse(_aiServiceUrl),
        headers: _headers,
        body: jsonEncode(payload),
      );

      print('📥 Risposta ricevuta da Python: ${aiResponse.statusCode}');

      if (aiResponse.statusCode == 200) {
        final data = jsonDecode(aiResponse.body);

        // Log formattato per debug
        _printFormattedJsonLog(data);

        return Response.ok(jsonEncode(data), headers: _headers);
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
