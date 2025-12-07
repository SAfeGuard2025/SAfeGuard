// Modello: Emergenza

class Emergenza {
  final String id;          // ID univoco del documento/segnalazione
  final String userId;      // ID dell'utente che ha inviato l'SOS
  final String? email;      // Email di contatto (opzionale)
  final String? phone;      // Telefono di contatto (opzionale)
  final String type;        // Tipo di emergenza (es. Generico, Medico, Incendio)
  final double lat;         // Latitudine GPS
  final double lng;         // Longitudine GPS
  final DateTime timestamp; // Data e ora dell'invio (standard Dart)
  final String status;      // Stato corrente (active, resolved, handled)

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

  // Factory per creare un oggetto da JSON (es. da API o DB).
  // Gestisce conversioni sicure di tipi (int->double) e date eterogenee.
  factory Emergenza.fromJson(Map<String, dynamic> json, [String? docId]) {
    return Emergenza(
      id: docId ?? json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      type: json['type']?.toString() ?? 'Generico',

      // Parsing robusto: accetta sia int che double senza crashare
      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : 0.0,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : 0.0,

      // Gestione universale della data (Stringa ISO o Timestamp Firebase)
      timestamp: _parseDate(json['timestamp']),

      status: json['status']?.toString() ?? 'active',
    );
  }

  // Converte l'oggetto in una Map JSON pura per l'invio via rete.
  // Standardizza la data in formato ISO8601 string.
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

  // Crea una copia dell'oggetto modificando solo i campi specificati.
  // Utile per aggiornamenti di stato immutabili.
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

  // Helper privati

  // Converte qualsiasi formato data in ingresso (null, String, Timestamp, DateTime)
  // in un DateTime Dart nativo, senza bisogno di importare librerie esterne.
  static DateTime _parseDate(dynamic input) {
    if (input == null) return DateTime.now();
    if (input is DateTime) return input;

    // Caso 1: Stringa
    if (input is String) {
      return DateTime.tryParse(input) ?? DateTime.now();
    }

    // Caso 2: Oggetto Timestamp
    try {
      // Usato 'dynamic' per chiamare .toDate() se esiste, evitando dipendenze dirette.
      return (input as dynamic).toDate();
    } catch (_) {
      return DateTime.now(); // Fallback in caso di formato sconosciuto
    }
  }
}