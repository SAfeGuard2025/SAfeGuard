// Modello: RiskHotspot
// Modelloche rappresenta un cluster di rischio geografico identificato dal motore AI.
// Fa da ponte tra i dati grezzi calcolati in Python (e salvati su Firestore) e la visualizzazione
// delle "zone calde" sulla mappa dell'applicazione.

class RiskHotspot {
  final int id;
  final double centerLat;
  final double centerLng;
  final int size; // Numero di eventi storici nel cluster (densità del rischio)
  final double radiusKm;
  final DateTime?
  lastUpdated; // Opzionale, data dell'ultimo ricalcolo del cluster

  // Costruttore principale.
  // Richiede tutti i parametri essenziali per definire geometricamente l'hotspot.
  RiskHotspot({
    required this.id,
    required this.centerLat,
    required this.centerLng,
    required this.size,
    required this.radiusKm,
    this.lastUpdated,
  });

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  // Include una logica robusta per gestire discrepanze di tipo (int vs double) che possono
  // verificarsi tra Python, Firestore e Dart.
  factory RiskHotspot.fromJson(Map<String, dynamic> json) {
    return RiskHotspot(
      // Gestione sicura dell'ID: Python invia int, ma Firestore a volte lo tratta come numero generico.
      // Se il cast diretto fallisce, tenta il parsing da stringa o usa -1 come fallback.
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? -1,

      // Gestione sicura delle coordinate: assicura che siano sempre double.
      centerLat: (json['center_lat'] is num)
          ? (json['center_lat'] as num).toDouble()
          : 0.0,

      centerLng: (json['center_lng'] is num)
          ? (json['center_lng'] as num).toDouble()
          : 0.0,

      // Gestione della dimensione del cluster.
      size: json['size'] is int
          ? json['size']
          : int.tryParse(json['size'].toString()) ?? 0,

      // Gestione del raggio.
      radiusKm: (json['radius_km'] is num)
          ? (json['radius_km'] as num).toDouble()
          : 0.0,

      // Gestione della data: Firestore potrebbe restituire una stringa.
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString())
          : null,
    );
  }

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_lat': centerLat,
      'center_lng': centerLng,
      'size': size,
      'radius_km': radiusKm,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}
