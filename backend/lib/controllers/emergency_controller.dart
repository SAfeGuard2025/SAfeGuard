import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/emergency_service.dart';

class EmergencyController {
  final EmergencyService _service = EmergencyService();

  // Router interno del controller
  Handler get router {
    final router = Router();

    // 1. INVIA SOS (POST /api/emergency)
    // L'utente invia i dati (GPS, tipo) e il server usa il suo ID dal token
    router.post('/', sendSos);

    // 2. STOP SOS (DELETE /api/emergency)
    // Cancella l'SOS dell'utente che fa la richiesta
    router.delete('/', _stopMySos);

    // 3. GET TUTTE LE EMERGENZE (GET /api/emergency/all)
    // (Opzionale: Solo per Soccorritori o Dashboard)
    router.get('/all', _getAllEmergencies);

    return router;
  }

  // --- HANDLERS ---

  /// Invia una nuova segnalazione di emergenza.
  Future<Response> sendSos(Request request) async {
    try {
      // 1. Recupero l'utente dal Context (iniettato dall'AuthGuard)
      // Questo è il passaggio FONDAMENTALE di sicurezza.
      final userContext = request.context['user'] as Map<String, dynamic>?;

      if (userContext == null) {
        return Response.forbidden(jsonEncode({'error': 'Utente non identificato'}));
      }

      final String userId = userContext['id'].toString();

      // 2. Leggo il Body della richiesta
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      // 3. Validazione dati minimi (GPS)
      if (data['lat'] == null || data['lng'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Coordinate GPS mancanti'}),
          headers: {'content-type': 'application/json'},
        );
      }

      // 4. Chiamo il Service per la logica di business
      await _service.processSosRequest(
        userId: userId,
        email: data['email'],
        phone: data['phone'],
        type: data['type'] ?? 'Generico',
        // Parsing sicuro dei numeri
        lat: (data['lat'] as num).toDouble(),
        lng: (data['lng'] as num).toDouble(),
      );

      return Response.ok(
        jsonEncode({'success': true, 'message': 'SOS Inviato con successo'}),
        headers: {'content-type': 'application/json'},
      );

    } catch (e) {
      print("Errore Controller SOS: $e");
      return Response.internalServerError(
        body: jsonEncode({'error': 'Errore interno del server: $e'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Cancella l'SOS dell'utente corrente.
  Future<Response> _stopMySos(Request request) async {
    try {
      final userContext = request.context['user'] as Map<String, dynamic>?;
      if (userContext == null) {
        return Response.forbidden(jsonEncode({'error': 'Non autorizzato'}));
      }

      final String userId = userContext['id'].toString();

      // Chiama il service per cancellare
      await _service.cancelSos(userId);

      return Response.ok(
        jsonEncode({'success': true, 'message': 'SOS Annullato'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Restituisce la lista di tutte le emergenze attive.
  Future<Response> _getAllEmergencies(Request request) async {
    try {
      // (Opzionale) Qui potresti controllare se userContext['type'] == 'soccorritore'

      final emergencies = await _service.getActiveEmergencies();

      return Response.ok(
        jsonEncode(emergencies),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}