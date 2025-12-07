import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/report_service.dart'; // Importa il Service

class ReportController {
  // Istanziamo il Service invece di chiamare Firestore direttamente
  final ReportService _reportService = ReportService();

  final Map<String, String> _headers = {'content-type': 'application/json'};

// POST /api/reports/create
  Future<Response> createReport(Request request) async {
    try {
      final userContext = request.context['user'] as Map<String, dynamic>?;
      if (userContext == null) {
        return Response.forbidden(jsonEncode({'error': 'Utente non autenticato'}));
      }

      final int senderId = userContext['id'];

      // 1. Estrazione sicura del tipo utente
      final String userType = userContext['type']?.toString() ?? 'Utente';

      // DEBUG: Stampa cosa vede il server
      print("🔍 DEBUG REPORT: ID: $senderId, Tipo Token: '$userType'");

      // Controllo case-insensitive per sicurezza
      final bool isSenderRescuer = userType.toLowerCase() == 'soccorritore';

      if (isSenderRescuer) {
        print("✅ Riconosciuto come SOCCORRITORE. Notificherò i cittadini.");
      } else {
        print("👤 Riconosciuto come CITTADINO. Notificherò i soccorritori.");
      }

      final body = await request.readAsString();
      if (body.isEmpty) return Response.badRequest(body: 'Nessun dato inviato');

      final Map<String, dynamic> data = jsonDecode(body);
      final String? type = data['type'];
      final String? description = data['description'];
      final double? lat = (data['lat'] as num?)?.toDouble();
      final double? lng = (data['lng'] as num?)?.toDouble();

      if (type == null || type.isEmpty) {
        return Response.badRequest(
            body: jsonEncode({'error': 'Il tipo di emergenza è obbligatorio'}),
            headers: _headers
        );
      }

      // 2. Passaggio al Service
      await _reportService.createReport(
        senderId: senderId,
        isSenderRescuer: isSenderRescuer, // <--- BOOLEANO CRUCIALE
        type: type,
        description: description,
        lat: lat,
        lng: lng,
      );

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Segnalazione creata con successo'}),
        headers: _headers,
      );
    } catch (e) {
      print("Errore controller createReport: $e");
      return Response.internalServerError(
          body: jsonEncode({'success': false, 'message': 'Errore server: $e'}),
          headers: _headers
      );
    }
  }

// GET /api/reports
  Future<Response> getAllReports(Request request) async {
    try {
      final list = await _reportService.getReports();

      return Response.ok(
        jsonEncode(list, toEncodable: (item) {
          if (item is DateTime) {
            return item.toIso8601String();
          }
          return item;
        }),
        headers: _headers,
      );

    } catch (e) {
      print("Errore controller getAllReports: $e");
      return Response.internalServerError(
          body: jsonEncode({'error': 'Impossibile recuperare le segnalazioni'}),
          headers: _headers
      );
    }
  }
  Future<Response> deleteReport(Request request, String id) async {
    try {
      await _reportService.closeReport(id);

      return Response.ok(
        jsonEncode({'success': true, 'message': 'Segnalazione chiusa'}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Impossibile chiudere la segnalazione: $e'}),
        headers: _headers,
      );
    }
    }
}