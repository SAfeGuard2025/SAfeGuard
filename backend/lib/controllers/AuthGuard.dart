import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/JWTService.dart';

class AuthGuard {
  final JWTService _jwtService = JWTService();

  Middleware get middleware => (Handler innerHandler) {
    return (Request request) async {
      // 1. Gestione pre-flight CORS
      if (request.method == 'OPTIONS') {
        return await innerHandler(request);
      }

      // 2. Verifica Header di Autorizzazione
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return _unauthorizedResponse('Token di autorizzazione mancante o malformato.');
      }

      // 3. Estrazione e validazione token di sessione
      // Isola la stringa del token e verifica firma/scadenza tramite il JWTService
      final token = authHeader.substring(7);
      final payload = _jwtService.verifyToken(token);

      if (payload == null) {
        return _unauthorizedResponse('Token non valido o scaduto. Effettuare nuovamente il login.');
      }

      // 4. Context Injection
      // Clona la richiesta aggiungendo i dati utente nel "context".
      // Accessibile via: request.context['user']['id']
      final updatedRequest = request.change(context: {
        'user': {
          'id': payload['id'],
          'type': payload['type'],
        }
      });

      // 5. Prosecuzione della catena di handler
      // Passa il controllo al prossimo handler con la richiesta aggiornata
      return await innerHandler(updatedRequest);
    };
  };

  // Helper per risposta 401 JSON standardizzata
  Response _unauthorizedResponse(String message) {
    return Response(
      401, // HTTP Status Code: Unauthorized
      body: jsonEncode({
        'success': false,
        'message': message,
      }),
      headers: {'content-type': 'application/json'},
    );
  }
}