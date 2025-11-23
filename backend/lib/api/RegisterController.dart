import 'dart:convert';
import '../services/RegisterService.dart';
import '../repositories/UserRepository.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';

class RegisterController {
  // Inizializzazione della dipendenza.
  final RegisterService _registerService = RegisterService(UserRepository());

  // Simula la gestione di una richiesta HTTP POST /api/register
  Future<String> handleRegisterRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> requestData = jsonDecode(requestBodyJson);
      // Estrae la password e la rimuove dal payload dei dati utente
      final password = requestData.remove('password') as String;

      final user = await _registerService.register(requestData, password);

      String tipoUtente;
      int assegnatoId;

      if (user is Soccorritore) {
        // Se è un Soccorritore, il compilatore sa che ha accesso al campo id
        tipoUtente = 'Soccorritore';
        assegnatoId = user.id;
      } else if (user is Utente) {
        // Se è un Utente, accediamo all'id di Utente
        tipoUtente = 'Utente Standard';
        assegnatoId = user.id;
      } else {
        // Caso di fallback (non dovrebbe succedere se la logica è corretta)
        tipoUtente = 'Sconosciuto';
        assegnatoId = 0;
      }

      final responseBody = {
        'success': true,
        'message': 'Registrazione avvenuta con successo. ID assegnato: $assegnatoId, Tipo Utente: $tipoUtente',
        'user': user.toJson()..remove('passwordHash'), // Rimuovi l'hash per il frontend
      };
      return jsonEncode(responseBody);

    } on Exception catch (e) {
      // Gestisce gli errori di business (es. utente già registrato)
      final responseBody = {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
      return jsonEncode(responseBody);
    } catch (e) {
      final responseBody = {
        'success': false,
        'message': 'Errore interno del server durante la registrazione.',
      };
      return jsonEncode(responseBody);
    }
  }
}