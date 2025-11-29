import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/logout_service.dart';

class LogoutController {
  // Dipendenza: il Controller delega la logica di logout al LogoutService.
  final LogoutService _logoutService = LogoutService();

  // Handler per l'API: POST /api/auth/logout
  Future<Response> handleLogout(Request request) async {
    // 1. Estrazione ID Utente
    // AuthGuard (controller che verifica il JWT) ha precedentemente iniettato
    // l'ID utente nel contesto della richiesta.
    final userIdFromToken = request.context['userId'] as String?;

    if (userIdFromToken == null) {
      // Se l'utente non è autenticato o il token è scaduto, si considera comunque la disconnessione completata.
      return Response.ok(
        jsonEncode({'message': 'Disconnessione completata.'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      // 2. Chiamata a LogoutService
      // Delega il compito di invalidare la sessione.
      final success = await _logoutService.signOut(userIdFromToken);

      if (success) {
        return Response.ok(
          jsonEncode({'message': 'Logout completato.'}),
          headers: {'Content-Type': 'application/json'},
        );
      } else {
        return Response.internalServerError(
          body: jsonEncode({'error': 'Disconnessione fallita lato server.'}),
        );
      }
    } catch (e) {
      print("Errore interno durante il logout: $e");
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Errore interno del server durante il logout.',
        }),
      );
    }
  }
}
