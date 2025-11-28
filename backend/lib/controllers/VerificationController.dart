import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:firedart/firedart.dart';

class VerificationController {
  final Map<String, String> _headers = {'content-type': 'application/json'};

  Future<Response> handleVerificationRequest(Request request) async {
    try {
      final String body = await request.readAsString();
      if (body.isEmpty) return _errorResponse('Body vuoto');

      final Map<String, dynamic> data = jsonDecode(body);
      final String? email = data['email'];
      final String? telefono = data['telefono'];
      final String? code = data['code'];

      if (code == null || (email == null && telefono == null)) {
        return _errorResponse('Dati mancanti (Email/Telefono e Codice richiesti).');
      }

      // --- LOGICA IBRIDA ---
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
      final verifyDocRef = Firestore.instance.collection(collectionName).document(docId);
      if (!await verifyDocRef.exists) {
        return _errorResponse('Nessuna richiesta di verifica trovata o scaduta.');
      }

      final verifyDoc = await verifyDocRef.get();
      final String serverOtp = verifyDoc['otp'];

      // 2. Confronto
      if (serverOtp == code) {
        // --- SUCCESSO ---

        final usersQuery = await Firestore.instance
            .collection('utenti')
            .where(fieldNameForQuery, isEqualTo: docId)
            .get();

        if (usersQuery.isNotEmpty) {
          final userDoc = usersQuery.first;
          await Firestore.instance.collection('utenti').document(userDoc.id).update({
            'attivo': true,
            'email_verified': true,
          });
        }

        // B. Cancelliamo l'OTP usato (per sicurezza e pulizia)
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

  Response _errorResponse(String msg) {
    return Response.badRequest(
      body: jsonEncode({'success': false, 'message': msg}),
      headers: _headers,
    );
  }
}