// File: backend/lib/controllers/emergenze_controller.dart

import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/emergenze_service.dart';

class EmergenzeController {
  final EmergenzeService _emergenzeService = EmergenzeService();

  // Handler per: POST /api/emergenze/sos
  Future<Response> handleSOSRequest(Request request) async {
    // Verifica utente loggato (dal middleware)
    final userContext = request.context['user'] as Map<String, dynamic>?;

    if (userContext == null) {
      return Response.forbidden(
        jsonEncode({'error': 'Utente non identificato.'}),
      );
    }

    try {
      final body = jsonDecode(await request.readAsString());

      // Validazione dati minimi
      if (body['latitude'] == null || body['longitude'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Coordinate mancanti'}),
        );
      }

      final double lat = (body['latitude'] as num).toDouble();
      final double lng = (body['longitude'] as num).toDouble();

      // Dati opzionali con default
      final String type = body['type'] ?? 'Emergenza Generica';
      final String description = body['description'] ?? '';

      // Generazione ID univoco per l'evento
      final String sosId =
          "${userContext['id']}-${DateTime.now().millisecondsSinceEpoch}";

      //  Estraggo l'ID dall'utente loggato
      final int senderId = userContext['id'];

      print('Ricevuto SOS da User $senderId: $type a ($lat, $lng)');

      // 2. Avvia la catena di notifiche
      await _emergenzeService.triggerSOSNotification(
        lat: lat,
        lng: lng,
        sosId: sosId,
        type: type,
        description: description,
        senderId: senderId,
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'SOS Inviato e processato',
          'sosId': sosId,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('❌ Errore Controller SOS: $e');
      print(stack);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Errore interno server'}),
      );
    }
  }
}
