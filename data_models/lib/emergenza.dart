// Modello: Emergenza
// Gestisce lo stato e i dati di una richiesta di soccorso o SOS attiva nel sistema.

class Emergenza {
  final String id;          // ID univoco della segnalazione
  final String userId;
  final String? email;
  final String? phone;
  final String type;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String status;      // Stato corrente (attiva, risolta)

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

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  // Gestisce conversioni sicure di tipi (int->double) e date eterogenee.
  factory Emergenza.fromJson(Map<String, dynamic> json, [String? docId]) {
    return Emergenza(
      id: docId ?? json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      type: json['type']?.toString() ?? 'Generico',

      lat: (json['lat'] is num) ? (json['lat'] as num).toDouble() : 0.0,
      lng: (json['lng'] is num) ? (json['lng'] as num).toDouble() : 0.0,

      // Gestione universale della data
      timestamp: _parseDate(json['timestamp']),

      status: json['status']?.toString() ?? 'active',
    );
  }

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'phone': phone,
      'type': type,
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  // Metodo copyWith: Fondamentale per la UI Flutter (Switch/Checkbox).
  // Permette di creare una nuova istanza dell'oggetto, modificando solo i campi specificati
  // mantenendo gli altri invariati.
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

  // Converte qualsiasi formato data in ingresso (null, String, Timestamp, DateTime)
  // in un DateTime Dart nativo.
  static DateTime _parseDate(dynamic input) {
    if (input == null) return DateTime.now();
    if (input is DateTime) return input;

    // Caso 1: Stringa
    if (input is String) {
      return DateTime.tryParse(input) ?? DateTime.now();
    }

    // Caso 2: Oggetto Timestamp
    try {
      return (input as dynamic).toDate();
    } catch (_) {
      return DateTime.now(); // Fallback in caso di formato sconosciuto
    }
  }
}