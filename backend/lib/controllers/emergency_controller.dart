import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/emergency_service.dart';

class EmergencyController {
  // Dipendenza: il Controller delega la logica di business a EmergencyService
  final EmergencyService _emergencyService = EmergencyService();

  // Header standard per risposte JSON
  final Map<String, String> _headers = {'content-type': 'application/json'};

  // Definizione delle rotte
  Handler get router {
    final router = Router();

    // Invio SOS
    router.post('/', handleSendSos);
    // Annullamento SOS
    router.delete('/', handleStopSos);
    // Lista completa (per dashboard/soccorritori)
    router.get('/all', handleGetAllEmergenciesRequest);
    // Tracking GPS in tempo reale
    router.patch('/location', handleUpdateLocation);

    return router.call;
  }

  // Gestisce l'invio di una nuova emergenza
  Future<Response> handleSendSos(Request request) async {
    try {
      final userId = _extractUserId(request);
      if (userId == null) return _buildErrorResponse(403, 'Utente non identificato');

      final body = await request.readAsString();
      if (body.isEmpty) return _buildErrorResponse(400, 'Body vuoto');

      final Map<String, dynamic> data = jsonDecode(body);

      // Verifica coordinate obbligatorie
      if (data['lat'] == null || data['lng'] == null) {
        return _buildErrorResponse(400, 'Coordinate GPS obbligatorie');
      }

      // Delega al service l'elaborazione e il salvataggio
      await _emergencyService.processSosRequest(
        userId: userId,
        email: data['email'],
        phone: data['phone'],
        type: data['type'] ?? 'Generico',
        // Parsing sicuro dei numeri
        lat: (data['lat'] as num).toDouble(),
        lng: (data['lng'] as num).toDouble(),
      );

      return _buildSuccessResponse('SOS Inviato con successo');
    } on FormatException {
      return _buildErrorResponse(400, 'JSON non valido');
    } catch (e) {
      return _buildErrorResponse(500, 'Errore server: $e');
    }
  }

  // Gestisce la cancellazione dell'SOS per l'utente corrente
  Future<Response> handleStopSos(Request request) async {
    try {
      final userId = _extractUserId(request);
      if (userId == null) return _buildErrorResponse(403, 'Non autorizzato');

      // Chiama il service per cancellare
      await _emergencyService.cancelSos(userId);

      return _buildSuccessResponse('SOS Annullato correttamente');
    } catch (e) {
      return _buildErrorResponse(500, 'Errore cancellazione: $e');
    }
  }

  // Aggiorna solo la posizione GPS in tempo reale
  Future<Response> handleUpdateLocation(Request request) async {
    try {
      final userId = _extractUserId(request);
      if (userId == null) return _buildErrorResponse(403, 'Non autorizzato');

      final body = await request.readAsString();
      final Map<String, dynamic> data = jsonDecode(body);

      if (data['lat'] == null || data['lng'] == null) {
        return _buildErrorResponse(400, 'Coordinate mancanti');
      }

      // Aggiornamento parziale tramite service
      await _emergencyService.updateUserLocation(
        userId,
        (data['lat'] as num).toDouble(),
        (data['lng'] as num).toDouble(),
      );

      return _buildSuccessResponse('Posizione aggiornata');
    } catch (e) {
      return _buildErrorResponse(500, '$e');
    }
  }

  // Restituisce la lista di tutte le emergenze attive
  Future<Response> handleGetAllEmergenciesRequest(Request request) async {
    try {
      final emergencies = await _emergencyService.getActiveEmergencies();
      return Response.ok(jsonEncode(emergencies), headers: _headers);
    } catch (e) {
      return _buildErrorResponse(500, 'Impossibile recuperare lista: $e');
    }
  }

  // Estrae l'ID utente dal context
  String? _extractUserId(Request request) {
    final userContext = request.context['user'] as Map<String, dynamic>?;
    return userContext?['id']?.toString();
  }

  // Helper per risposta 200 OK standard
  Response _buildSuccessResponse(String message, {Map<String, dynamic>? data}) {
    final responseBody = {
      'success': true,
      'message': message,
      if (data != null) ...data,
    };
    return Response.ok(jsonEncode(responseBody), headers: _headers);
  }

  // Helper per risposte di errore
  Response _buildErrorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'success': false, 'message': message}),
      headers: _headers,
    );
  }
}