import 'dart:convert';
import '../services/RegisterService.dart';
import '../services/VerificationService.dart';
import '../services/SmsService.dart';
import '../repositories/UserRepository.dart';

import 'package:data_models/Utente.dart';
import 'package:data_models/Soccorritore.dart';

class RegisterController {
  final RegisterService _registerService = RegisterService(
    UserRepository(), // Inietta UserRepository per RegisterService
    VerificationService(
      UserRepository(), // Inietta UserRepository per VerificationService
      SmsService(), // Inietta SmsService per VerificationService
    ),
  );

  // Simula la gestione di una richiesta HTTP POST /api/register
  Future<String> handleRegisterRequest(String requestBodyJson) async {
    try {
      final Map<String, dynamic> requestData = jsonDecode(requestBodyJson);

      // La password è necessaria
      final password = requestData.remove('password') as String;

      // Il resto dei dati (inclusi email e telefono opzionali) va al service
      final user = await _registerService.register(requestData, password);

      // Controllo del tipo e recupero ID (richiede che id sia in UtenteGenerico)
      String tipoUtente;
      final int assegnatoId = user.id!;

      if (user is Soccorritore) {
        tipoUtente = 'Soccorritore';
      } else if (user is Utente) {
        tipoUtente = 'Utente Standard';
      } else {
        tipoUtente = 'Generico';
        // Questo non dovrebbe accadere se la logica di deserializzazione è corretta
      }

      final responseBody = {
        'success': true,
        'message':
            'Registrazione avvenuta con successo. Tipo: $tipoUtente, ID assegnato: $assegnatoId',
        'user': user.toJson()..remove('passwordHash'),
      };
      return jsonEncode(responseBody);
    } on Exception catch (e) {
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
