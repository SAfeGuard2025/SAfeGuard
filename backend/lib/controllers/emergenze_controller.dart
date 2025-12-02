// File: backend/lib/controllers/emergenze_controller.dart

import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/emergenze_service.dart';

class EmergenzeController {
  final EmergenzeService _emergenzeService = EmergenzeService();

  // Handler per la rotta: POST /api/v1/emergenze/sos (Lancia SOS)
  Future<Response> handleSOSRequest(Request request) async {
    // Il token è già stato verificato dal middleware
    final userContext = request.context['user'] as Map<String, dynamic>?;

    if (userContext == null) {
      return Response.forbidden(jsonEncode({'error': 'Dati utente non disponibili.'}));
    }

    try {
      final body = jsonDecode(await request.readAsString());

      // Estrai i dati essenziali dall'app client
      final double lat = body['latitude'] as double;
      final double lng = body['longitude'] as double;
      final String sosId = userContext['id'].toString() + '-' + DateTime.now().millisecondsSinceEpoch.toString(); // ID SOS

      // 1. Logica di salvataggio SOS nel DB (Simulazione)
      // Qui dovresti salvare l'SOS nel database (collezione 'segnalazioni').
      print('Nuova segnalazione SOS salvata in DB: $sosId');

      // 2. Trigger Notifiche (Logica di Targeting)
      await _emergenzeService.triggerSOSNotification(lat, lng, sosId);

      // Risposta 200 OK (La notifica è stata avviata con successo)
      return Response.ok(jsonEncode({
        'success': true,
        'message': 'Richiesta SOS ricevuta e notifiche avviate.',
        'sosId': sosId,
      }), headers: {'Content-Type': 'application/json'});

    } catch (e) {
      print('❌ Errore nel Controller SOS: $e');
      return Response.badRequest(body: jsonEncode({'error': 'Dati SOS non validi o mancanti.'}));
    }
  }
}