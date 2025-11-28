import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/ProfileService.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Permesso.dart';
import 'package:data_models/Notifica.dart';
import 'package:data_models/Condizione.dart';
import 'package:data_models/ContattoEmergenza.dart';

class ProfileController {
  final ProfileService _profileService = ProfileService();

  // Helper per estrarre l'ID utente dal contesto (iniettato da AuthGuard)
  int? _getUserId(Request request) {
    final user = request.context['user'] as Map<String, dynamic>?;
    return user?['id'] as int?;
  }

  // Helper per risposte JSON
  Response _jsonResponse(int statusCode, {required Map<String, dynamic> body}) {
    return Response(
      statusCode,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // --- 1. GET /profile ---
  Future<Response> getProfile(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final userProfile = await _profileService.getProfile(userId);
    if (userProfile != null) {
      return _jsonResponse(200, body: userProfile.toJson());
    } else {
      return _jsonResponse(404, body: {'error': 'Profilo non trovato'});
    }
  }

  // --- 2. PUT /profile/anagrafica ---
  Future<Response> updateAnagrafica(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());

    final success = await _profileService.updateAnagrafica(
      userId,
      nome: body['nome'],
      cognome: body['cognome'],
      telefono: body['telefono'],
      citta: body['cittaDiNascita'],
      // Passiamo l'email ricevuta dal frontend
      email: body['email'], // <--- AGGIUNTO
      dataNascita: body['dataDiNascita'] != null ? DateTime.parse(body['dataDiNascita']) : null,
    );

    if (success) {
      return _jsonResponse(200, body: {'message': 'Anagrafica aggiornata'});
    } else {
      return _jsonResponse(500, body: {'error': 'Errore durante l\'aggiornamento'});
    }
  }

  // --- 3. PUT /profile/permessi ---
  Future<Response> updatePermessi(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final permessi = Permesso.fromJson(body);
    final success = await _profileService.updatePermessi(userId, permessi);

    if (success) {
      return _jsonResponse(200, body: {'message': 'Permessi aggiornati'});
    } else {
      return _jsonResponse(500, body: {'error': 'Errore durante l\'aggiornamento'});
    }
  }

    // --- 4. PUT /profile/condizioni ---
  Future<Response> updateCondizioni(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final condizioni = Condizione.fromJson(body);
    final success = await _profileService.updateCondizioni(userId, condizioni);

    if (success) {
      return _jsonResponse(200, body: {'message': 'Condizioni aggiornate'});
    } else {
      return _jsonResponse(500, body: {'error': 'Errore durante l\'aggiornamento'});
    }
  }

  // --- 5. PUT /profile/notifiche ---
  Future<Response> updateNotifiche(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final notifiche = Notifica.fromJson(body);
    final success = await _profileService.updateNotifiche(userId, notifiche);

    if (success) {
      return _jsonResponse(200, body: {'message': 'Notifiche aggiornate'});
    } else {
      return _jsonResponse(500, body: {'error': 'Errore durante l\'aggiornamento'});
    }
  }

  // --- 6. POST /profile/allergie ---
  Future<Response> addAllergia(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final allergia = body['allergia'] as String;
    await _profileService.addAllergia(userId, allergia);
    return _jsonResponse(201, body: {'message': 'Allergia aggiunta'});
  }

  // --- 7. DELETE /profile/allergie ---
  Future<Response> removeAllergia(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final allergia = body['allergia'] as String;
    await _profileService.removeAllergia(userId, allergia);
    return _jsonResponse(200, body: {'message': 'Allergia rimossa'});
  }

    // --- 8. POST /profile/medicinali ---
  Future<Response> addMedicinale(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final farmaco = body['medicinale'] as String;
    await _profileService.addMedicinale(userId, farmaco);
    return _jsonResponse(201, body: {'message': 'Medicinale aggiunto'});
  }

  // --- 9. DELETE /profile/medicinali ---
  Future<Response> removeMedicinale(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final farmaco = body['medicinale'] as String;
    await _profileService.removeMedicinale(userId, farmaco);
    return _jsonResponse(200, body: {'message': 'Medicinale rimosso'});
  }

  // --- 10. POST /profile/contatti ---
  Future<Response> addContatto(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final contatto = ContattoEmergenza.fromJson(body);
    await _profileService.addContatto(userId, contatto);
    return _jsonResponse(201, body: {'message': 'Contatto aggiunto'});
  }

  // --- 11. DELETE /profile/contatti ---
  Future<Response> removeContatto(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final contatto = ContattoEmergenza.fromJson(body);
    await _profileService.removeContatto(userId, contatto);
    return _jsonResponse(200, body: {'message': 'Contatto rimosso'});
  }

  // --- 12. PUT /profile/password ---
  Future<Response> updatePassword(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final body = jsonDecode(await request.readAsString());
    final oldPassword = body['oldPassword'] as String;
    final newPassword = body['newPassword'] as String;

    final error = await _profileService.updatePassword(userId, oldPassword, newPassword);
    if (error == null) {
      return _jsonResponse(200, body: {'message': 'Password aggiornata'});
    } else {
      return _jsonResponse(400, body: {'error': error});
    }
  }

  // --- 13. DELETE /profile ---
  Future<Response> deleteAccount(Request request) async {
    final userId = _getUserId(request);
    if (userId == null) return _jsonResponse(401, body: {'error': 'Non autorizzato'});

    final success = await _profileService.deleteAccount(userId);
    if (success) {
      return _jsonResponse(200, body: {'message': 'Account eliminato'});
    } else {
      return _jsonResponse(500, body: {'error': 'Errore durante l\'eliminazione'});
    }
  }
}
