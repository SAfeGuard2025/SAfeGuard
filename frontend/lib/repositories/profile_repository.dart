import 'dart:convert';
import 'dart:io';
import 'package:data_models/Condizione.dart';
import 'package:data_models/ContattoEmergenza.dart';
import 'package:data_models/Notifica.dart';
import 'package:data_models/Permesso.dart';
import 'package:data_models/Soccorritore.dart';
import 'package:data_models/Utente.dart';
import 'package:data_models/UtenteGenerico.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// ** Repository: ProfileRepository **
// Classe che gestisce le chiamate API per la lettura e modifica del profilo utente.
class ProfileRepository {

  // Metodo per determinare l'URL base del Backend in base alla piattaforma
  String get _baseUrl {
    String host = 'http://localhost';
    if (!kIsWeb && Platform.isAndroid) {
      host = 'http://10.0.2.2';
    }
    return '$host:8080';
  }

  // Metodo helper per recuperare il JWT salvato localmente
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Recupera la lista delle allergie dal profilo completo
  Future<List<String>> fetchAllergies() async {
    final token = await _getToken();
    // Prende tutto il profilo
    final url = Uri.parse('$_baseUrl/api/profile/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // JWT per autenticazione
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Estrae e converte la lista 'allergie'
      return List<String>.from(data['allergie'] ?? []);
    } else {
      throw Exception('Impossibile caricare le allergie');
    }
  }

  // Aggiunge un'allergia al profilo
  Future<void> addAllergia(String allergia) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/allergie');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'allergia': allergia}), // Invia l'allergia nel body
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Errore aggiunta allergia: ${response.body}');
    }
  }

  // Rimuove un'allergia dal profilo
  Future<void> removeAllergia(String allergia) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/allergie');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'allergia': allergia}), // Invia l'allergia da rimuovere
    );

    if (response.statusCode != 200) {
      throw Exception('Errore rimozione allergia');
    }
  }

  // Recupera la lista dei medicinali dal profilo completo
  Future<List<String>> fetchMedicines() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['medicinali'] ?? []);
    } else {
      throw Exception('Impossibile caricare i medicinali');
    }
  }

  // Aggiunge un medicinale al profilo
  Future<void> addMedicinale(String farmaco) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/medicinali');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'medicinale': farmaco}), // Invia il mediinale nel body
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Errore aggiunta medicinale: ${response.body}');
    }
  }

  // Rimuove un medicinale dal profilo
  Future<void> removeMedicinale(String farmaco) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/medicinali');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'medicinale': farmaco}), // Invia il medicinale da rimuovere
    );

    if (response.statusCode != 200) {
      throw Exception('Errore rimozione medicinale');
    }
  }

  // Recupera la lista dei contatti di emergenza
  Future<List<ContattoEmergenza>> fetchContacts() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['contattiEmergenza'] as List<dynamic>? ?? [];
      // Mappa gli oggetti JSON in istanze di ContattoEmergenza
      return list.map((e) => ContattoEmergenza.fromJson(e)).toList();
    } else {
      throw Exception('Impossibile caricare i contatti');
    }
  }

  // Aggiunge un ContattoEmergenza alla lista
  Future<void> addContatto(ContattoEmergenza contatto) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/contatti');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(contatto.toJson()), // Serializza l'oggetto ContattoEmergenza
    );

    if (response.statusCode != 201) {
      throw Exception('Errore aggiunta contatto: ${response.body}');
    }
  }

  // Rimuove un ContattoEmergenza dalla lista
  Future<void> removeContatto(ContattoEmergenza contatto) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/contatti');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(contatto.toJson()), // Invia l'oggetto da rimuovere
    );

    if (response.statusCode != 200) {
      throw Exception('Errore rimozione contatto');
    }
  }

  // Recupera l'oggetto Condizione dal profilo
  Future<Condizione> fetchCondizioni() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['condizioni'] != null) {
        return Condizione.fromJson(data['condizioni']); // Deserializza l'oggetto nidificato
      }
      return Condizione(); // Ritorna l'oggetto di default se non trovato
    } else {
      throw Exception('Impossibile caricare le condizioni');
    }
  }

  // Aggiorna l'oggetto Condizione nel profilo
  Future<void> updateCondizioni(Condizione condizioni) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/condizioni');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(condizioni.toJson()), // Serializza l'oggetto Condizione
    );

    if (response.statusCode != 200) {
      throw Exception('Errore aggiornamento condizioni: ${response.body}');
    }
  }

  // Recupera l'oggetto Permesso dal profilo
  Future<Permesso> fetchPermessi() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['permessi'] != null) {
        return Permesso.fromJson(data['permessi']); // Deserializza l'oggetto nidificato
      }
      return Permesso(); // Ritorna l'oggetto di default se non trovato
    } else {
      throw Exception('Impossibile caricare i permessi');
    }
  }

  // Aggiorna l'oggetto Permesso nel profilo
  Future<void> updatePermessi(Permesso permessi) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/permessi');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(permessi.toJson()), // Serializza l'oggetto Permesso
    );

    if (response.statusCode != 200) {
      throw Exception('Errore aggiornamento permessi: ${response.body}');
    }
  }

  // Recupera l'oggetto Notifica dal profilo
  Future<Notifica> fetchNotifiche() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['notifiche'] != null) {
        return Notifica.fromJson(data['notifiche']); // Deserializza l'oggetto nidificato
      }
      return Notifica(); // Ritorna l'oggetto di default se non trovato
    } else {
      throw Exception('Impossibile caricare le notifiche');
    }
  }

  // Aggiorna l'oggetto Notifica nel profilo
  Future<void> updateNotifiche(Notifica notifiche) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/notifiche');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(notifiche.toJson()), // Serializza l'oggetto Notifica
    );

    if (response.statusCode != 200) {
      throw Exception('Errore aggiornamento notifiche: ${response.body}');
    }
  }

  // Aggiorna i campi anagrafici (nome, telefono, email, ecc.) del profilo
  Future<bool> updateAnagrafica({
    String? nome,
    String? cognome,
    String? telefono,
    String? citta,
    String? email,
  }) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/anagrafica');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nome': nome,
        'cognome': cognome,
        'telefono': telefono,
        'email': email,
        'cittaDiNascita': citta,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Errore aggiornamento: ${response.body}');
    }
  }

  // Ricarica l'intero profilo utente e restituisce l'oggetto Utente o Soccorritore
  Future<UtenteGenerico?> getUserProfile() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Logica per distinguere i tipi di utente
      if (data['isSoccorritore'] == true) {
        return Soccorritore.fromJson(data);
      } else {
        return Utente.fromJson(data);
      }
    } else {
      throw Exception('Impossibile ricaricare il profilo');
    }
  }
}