import 'dart:convert';
import 'dart:io';
import 'package:data_models/Condizione.dart';
import 'package:data_models/ContattoEmergenza.dart';
import 'package:data_models/Notifica.dart';
import 'package:data_models/Permesso.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Per kIsWeb

class ProfileRepository {
  // Configurazione URL dinamica come nel tuo AuthRepository
  String get _baseUrl {
    String host = 'http://localhost';
    if (!kIsWeb && Platform.isAndroid) {
      host = 'http://10.0.2.2';
    }
    return '$host:8080';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- GET ALLERGIE (Dal profilo utente) ---
  Future<List<String>> fetchAllergies() async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/'); // Prende tutto il profilo

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assumiamo che il backend ritorni l'oggetto Utente con la lista 'allergie'
      return List<String>.from(data['allergie'] ?? []);
    } else {
      throw Exception('Impossibile caricare le allergie');
    }
  }

  // --- AGGIUNGI ALLERGIA ---
  Future<void> addAllergia(String allergia) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/allergie');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'allergia': allergia}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Errore aggiunta allergia: ${response.body}');
    }
  }

  // --- RIMUOVI ALLERGIA ---
  Future<void> removeAllergia(String allergia) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/allergie');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'allergia': allergia}),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore rimozione allergia');
    }
  }


  // --- GET MEDICINALI ---
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

  // --- AGGIUNGI MEDICINALE ---
  Future<void> addMedicinale(String farmaco) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/medicinali');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Nota: la chiave JSON deve coincidere con quella che il controller si aspetta (vedi source 98: 'medicinale')
      body: jsonEncode({'medicinale': farmaco}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Errore aggiunta medicinale: ${response.body}');
    }
  }

  // --- RIMUOVI MEDICINALE ---
  Future<void> removeMedicinale(String farmaco) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/medicinali');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'medicinale': farmaco}),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore rimozione medicinale');
    }
  }

  // --- GET CONTATTI ---
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
      return list.map((e) => ContattoEmergenza.fromJson(e)).toList();
    } else {
      throw Exception('Impossibile caricare i contatti');
    }
  }

  // --- AGGIUNGI CONTATTO ---
  Future<void> addContatto(ContattoEmergenza contatto) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/contatti');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(contatto.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Errore aggiunta contatto: ${response.body}');
    }
  }

  // --- RIMUOVI CONTATTO ---
  Future<void> removeContatto(ContattoEmergenza contatto) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/contatti');

    // Nelle chiamate DELETE con body, a volte è necessario specificare bene il client,
    // ma con http standard di Dart funziona passando il body.
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(contatto.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore rimozione contatto');
    }
  }

  // --- GET CONDIZIONI ---
  Future<Condizione> fetchCondizioni() async {
    final token = await _getToken();
    // Usiamo la rotta base del profilo che restituisce tutto l'utente [cite: 565]
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
      // Estraiamo solo la parte relativa alle condizioni
      if (data['condizioni'] != null) {
        return Condizione.fromJson(data['condizioni']);
      }
      return Condizione(); // Ritorna default (tutto false) se null
    } else {
      throw Exception('Impossibile caricare le condizioni');
    }
  }

  // --- UPDATE CONDIZIONI ---
  Future<void> updateCondizioni(Condizione condizioni) async {
    final token = await _getToken();
    // Endpoint specifico definito nel backend
    final url = Uri.parse('$_baseUrl/api/profile/condizioni');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(condizioni.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore aggiornamento condizioni: ${response.body}');
    }
  }

  // --- GET PERMESSI ---
  Future<Permesso> fetchPermessi() async {
    final token = await _getToken();
    // Usiamo la rotta base del profilo che restituisce tutto l'utente
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
      // Estraiamo solo la parte relativa ai permessi
      if (data['permessi'] != null) {
        return Permesso.fromJson(data['permessi']);
      }
      return Permesso(); // Ritorna default (tutto false) se null
    } else {
      throw Exception('Impossibile caricare i permessi');
    }
  }

  // --- UPDATE PERMESSI ---
  Future<void> updatePermessi(Permesso permessi) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/permessi');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(permessi.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore aggiornamento permessi: ${response.body}');
    }
  }

  // --- GET NOTIFICHE ---
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
        return Notifica.fromJson(data['notifiche']);
      }
      return Notifica(); // Default
    } else {
      throw Exception('Impossibile caricare le notifiche');
    }
  }

  // --- UPDATE NOTIFICHE ---
  Future<void> updateNotifiche(Notifica notifiche) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/notifiche');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(notifiche.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore aggiornamento notifiche: ${response.body}');
    }
  }
}