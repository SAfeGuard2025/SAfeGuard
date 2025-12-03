import 'dart:convert';
import 'dart:io';
import 'package:data_models/condizione.dart';
import 'package:data_models/contatto_emergenza.dart';
import 'package:data_models/notifica.dart';
import 'package:data_models/permesso.dart';
import 'package:data_models/soccorritore.dart';
import 'package:data_models/utente.dart';
import 'package:data_models/utente_generico.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ProfileRepository {
  static const String _envHost = String.fromEnvironment('SERVER_HOST', defaultValue: 'http://localhost');
  static const String _envPort = String.fromEnvironment('SERVER_PORT', defaultValue: '8080');
  static const String _envPrefix = String.fromEnvironment('API_PREFIX', defaultValue: '');

  String get _baseUrl {
    String host = _envHost;
    if (!kIsWeb && Platform.isAndroid && host.contains('localhost')) {
      host = host.replaceFirst('localhost', '10.0.2.2');
    }
    final String portPart = _envPort == '-1' ? '' : ':$_envPort';
    return '$host$portPart$_envPrefix';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<String>> fetchAllergies() async {
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
      return List<String>.from(data['allergie'] ?? []);
    } else {
      throw Exception('Impossibile caricare le allergie');
    }
  }

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

  Future<void> addMedicinale(String farmaco) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/medicinali');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'medicinale': farmaco}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Errore aggiunta medicinale: ${response.body}');
    }
  }

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

  Future<void> removeContatto(ContattoEmergenza contatto) async {
    final token = await _getToken();
    final url = Uri.parse('$_baseUrl/api/profile/contatti');
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
        return Condizione.fromJson(data['condizioni']);
      }
      return Condizione();
    } else {
      throw Exception('Impossibile caricare le condizioni');
    }
  }

  Future<void> updateCondizioni(Condizione condizioni) async {
    final token = await _getToken();
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
        return Permesso.fromJson(data['permessi']);
      }
      return Permesso();
    } else {
      throw Exception('Impossibile caricare i permessi');
    }
  }

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
      return Notifica();
    } else {
      throw Exception('Impossibile caricare le notifiche');
    }
  }

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
      if (data['isSoccorritore'] == true) {
        return Soccorritore.fromJson(data);
      } else {
        return Utente.fromJson(data);
      }
    } else {
      throw Exception('Impossibile ricaricare il profilo');
    }
  }

  // Elimina account
  Future<void> deleteAccount() async {
    final token = await _getToken();
    final url = Uri.parse(
      '$_baseUrl/api/profile/',
    ); //endpoint presente nel controller backend
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Errore durante l\'eliminazione dell\'account: ${response.body}',
      );
    }
  }
}
