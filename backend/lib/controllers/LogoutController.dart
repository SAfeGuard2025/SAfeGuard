// File: backend/lib/controllers/LogoutController.dart

import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/LogoutService.dart';

class LogoutController {
  final LogoutService _logoutService = LogoutService();

  // Handler per l'API: POST /api/auth/logout
  Future<Response> handleLogout(Request request) async {

    // Assumiamo che il middleware di autenticazione abbia estratto l'ID utente dal token JWT
    // e messo l'ID stringa nel contesto.
    final userIdFromToken = request.context['userId'] as String?;

    if (userIdFromToken == null) {
      // Se l'utente non è autenticato o il token è scaduto, si considera comunque la disconnessione completata.
      return Response.ok(jsonEncode({'message': 'Disconnessione completata.'}), headers: {'Content-Type': 'application/json'});
    }

    try {
      final success = await _logoutService.signOut(userIdFromToken);

      if (success) {
        // Risposta 200 OK per confermare la disconnessione
        // Aggiungi un header per forzare la scadenza di cookie (se usati)
        return Response.ok(jsonEncode({'message': 'Logout completato.'}), headers: {'Content-Type': 'application/json'});
      } else {
        return Response.internalServerError(body: jsonEncode({'error': 'Disconnessione fallita lato server.'}));
      }
    } catch (e) {
      print("Errore interno durante il logout: $e");
      return Response.internalServerError(body: jsonEncode({'error': 'Errore interno del server durante il logout.'}));
    }
  }
}