// File: lib/api/AuthGuard.dart

import 'dart:convert';
import 'dart:io'; // Per gestire la richiesta/risposta HTTP (simulazione)
import '../services/JWTService.dart';

class AuthGuard {
  final JWTService _jwtService = JWTService();

  // La funzione middleware: prende l'handler e ne restituisce uno nuovo "protetto"
  Future<String> protect(
    HttpRequest request,
    Future<String> Function(HttpRequest) nextHandler,
  ) async {
    // 1. Estrai il Token dall'header
    final authHeader = request.headers.value('authorization');

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      // 401 Unauthorized: Header mancante o malformato
      return _unauthorizedResponse('Token di autorizzazione mancante.');
    }

    // Rimuovi il prefisso 'Bearer '
    final token = authHeader.substring(7);

    // 2. Verifica e Decodifica il Token
    final payload = _jwtService.verifyToken(token);

    if (payload == null) {
      // 401 Unauthorized: Token non valido o scaduto
      return _unauthorizedResponse(
        'Token non valido o scaduto. Effettuare nuovamente il login.',
      );
    }

    // 3. Inietta i dati dell'utente nella richiesta per l'handler successivo
    // (In un server Dart reale, i dati verrebbero iniettati in un oggetto RequestContext)
    // Per la nostra simulazione, assumeremo che l'ID sia passato implicitamente:

    // L'ID utente è ora disponibile per i servizi successivi:
    final userId = payload['id'] as int;
    final userType = payload['type'] as String;

    print('Autenticazione Riuscita: Utente ID $userId ($userType) ha accesso.');

    // 4. Se la verifica ha successo, esegui l'handler originale
    // Potresti voler passare i dati dell'utente come argomento all'handler se possibile.
    // Per semplicità, richiamiamo l'handler originale, assumendo che i servizi possano
    // accedere all'ID utente da un contesto globale simulato, se necessario.

    // --- SIMULAZIONE DI INIEZIONE DATI ---
    //_SimulatedRequestContext.currentUserId = userId;
    // ------------------------------------

    try {
      return await nextHandler(request);
    } finally {
      /*_SimulatedRequestContext.currentUserId =
          null; // Pulisci dopo l'esecuzione
       */
    }
  }

  // Funzione di utilità per la risposta 401
  String _unauthorizedResponse(String message) {
    // In un framework reale, imposteresti lo stato HTTP a 401
    return jsonEncode({
      'success': false,
      'message': message,
      'statusCode': 401,
    });
  }
}

// Classe fittizia per simulare un contesto globale dove iniettare l'ID utente
// in un'app server reale, questo sarebbe gestito dal framework.
/*class _SimulatedRequestContext {
  static int? currentUserId;
}*/
