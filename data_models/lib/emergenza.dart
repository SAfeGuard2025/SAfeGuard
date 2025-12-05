// Modello: Emergenza
// Versione "Pure Dart": Non ha dipendenze esterne (no firebase, no firedart).
// Compatibile al 100% sia con Frontend che con Backend.

class Emergenza {
  final String id; // ID del documento
  final String userId; // ID dell'utente
  final String? email; // Email contatto
  final String? phone; // Telefono contatto
  final String type; // Tipo (es. Generico, Medico)
  final double lat; // Latitudine
  final double lng; // Longitudine
  final DateTime timestamp; // Usiamo DateTime nativo di Dart
  final String status; // Status (active, resolved)

  Emergenza({
    required this.id,
    required this.userId,
    this.email,
    this.phone,
    required this.type,
    required this.lat,
    required this.lng,
    required this.timestamp,
    required this.status,
  });

  // Factory per creare un oggetto partendo da una Map JSON.
  // Accetta 'docId' opzionale perché a volte l'ID è la chiave del documento.
  factory Emergenza.fromJson(Map<String, dynamic> json, [String? docId]) {
    return Emergenza(
      id: docId ?? json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      type: json['type']?.toString() ?? 'Generico',

      // Parsing robusto per i numeri (gestisce sia int che double senza crashare)
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : 0.0,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : 0.0,

      // Gestione intelligente della data (funziona con Stringhe ISO, DateTime e Timestamp)
      timestamp: _parseDate(json['timestamp']),

      status: json['status']?.toString() ?? 'active',
    );
  }

  // Converte l'oggetto in una Map JSON pura.
  // Utile per inviare i dati via HTTP o per salvarli su DB.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'phone': phone,
      'type': type,
      'lat': lat,
      'lng': lng,
      // Salviamo la data come stringa ISO8601 per massima compatibilità
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  // Metodo copyWith: utile per modificare solo alcuni campi (es. aggiornare posizione)
  Emergenza copyWith({
    String? id,
    String? userId,
    String? email,
    String? phone,
    String? type,
    double? lat,
    double? lng,
    DateTime? timestamp,
    String? status,
  }) {
    return Emergenza(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
  static DateTime _parseDate(dynamic input) {
    if (input == null) return DateTime.now();

    // 1. Se è già DateTime
    if (input is DateTime) return input;

    // 2. Se è Stringa (es. da API JSON)
    if (input is String) {
      return DateTime.tryParse(input) ?? DateTime.now();
    }

    // 3. Se è un oggetto Timestamp (da Firestore o Firedart)
    // Usiamo 'dynamic' per chiamare .toDate() se esiste
    try {
      return (input as dynamic).toDate();
    } catch (_) {
      return DateTime.now(); // Fallback
    }
  }
}