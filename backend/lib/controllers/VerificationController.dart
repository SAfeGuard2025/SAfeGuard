import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:firedart/firedart.dart';

class VerificationController {
  final Map<String, String> _headers = {'content-type': 'application/json'};

  // Handler per l'API: POST /api/verify
  Future<Response> handleVerificationRequest(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _errorResponse('Body vuoto');

      final Map<String, dynamic> data = jsonDecode(body);
      final String? email = (data['email'] as String?)?.toLowerCase();
      final String? telefono = (data['telefono'] as String?)?.replaceAll(
        ' ',
        '',
      );
      final String? code = data['code']; // Codice OTP inviato dal frontend

      if (code == null || (email == null && telefono == null)) {
        return _errorResponse(
          'Dati mancanti (Email/Telefono e Codice richiesti).',
        );
      }

      // Logica Ibrida: Email o Telefono
      // Decide quale collezione usare (email_verifications o phone_verifications)
      String collectionName;
      String docId;
      String fieldNameForQuery;

      if (email != null) {
        collectionName = 'email_verifications';
        docId = email;
        fieldNameForQuery = 'email';
      } else {
        collectionName = 'phone_verifications';
        docId = telefono!;
        fieldNameForQuery = 'telefono';
      }

      // 1. Recupero OTP dal DB
      final verifyDocRef = Firestore.instance
          .collection(collectionName)
          .document(docId);
      if (!await verifyDocRef.exists) {
        return _errorResponse(
          'Nessuna richiesta di verifica trovata o scaduta.',
        );
      }

      final verifyDoc = await verifyDocRef.get();
      final String serverOtp = verifyDoc['otp'];

      // 2. Confronto OTP
      if (serverOtp == code) {
        // Aggiornamente stato utente
        // Trova l'utente corrispondente usando l'email/telefono
        final usersQuery = await Firestore.instance
            .collection('utenti')
            .where(fieldNameForQuery, isEqualTo: docId)
            .get();

        if (usersQuery.isNotEmpty) {
          final userDoc = usersQuery.first;
          await Firestore.instance
              .collection('utenti')
              .document(userDoc.id)
              .update({'attivo': true, 'email_verified': true});
        }

        //  Cancelliazzione dell'OTP usato
        await verifyDocRef.delete();

        return Response.ok(
          jsonEncode({'success': true, 'message': 'Verifica riuscita.'}),
          headers: _headers,
        );
      } else {
        return _errorResponse('Codice OTP errato.');
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'message': 'Errore server: $e'}),
        headers: _headers,
      );
    }
  }

  // Helper per costruire risposte di Errore 400 (Bad Request)
  Response _errorResponse(String msg) {
    return Response.badRequest(
      body: jsonEncode({'success': false, 'message': msg}),
      headers: _headers,
    );
  }
}
