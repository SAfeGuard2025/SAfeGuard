// Modello: Permesso
// Classe immutabile che fa da ponte tra i permessi del Sistema Operativo (Android/iOS)
// richiesti dall'app (es. GPS, Notifiche) e lo stato salvato nel database.

class Permesso {
  final bool posizione;
  final bool contatti;
  final bool notificheSistema;
  final bool bluetooth;

  // Costruttore con valori di default a 'false'.
  Permesso({
    this.posizione = false,
    this.contatti = false,
    this.notificheSistema = false,
    this.bluetooth = false,
  });

  // Metodo copyWith: Fondamentale per la UI Flutter (Switch/Checkbox).
  // Permette di creare una nuova istanza dell'oggetto, modificando solo i campi specificati
  // mantenendo gli altri invariati.
  Permesso copyWith({
    bool? posizione,
    bool? contatti,
    bool? notificheSistema,
    bool? bluetooth,
  }) {
    return Permesso(
      posizione: posizione ?? this.posizione,
      contatti: contatti ?? this.contatti,
      notificheSistema: notificheSistema ?? this.notificheSistema,
      bluetooth: bluetooth ?? this.bluetooth,
    );
  }

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  // Utilizzato dal ProfileService per salvare lo stato nel campo 'permessi' dell'utente nel DB.
  Map<String, dynamic> toJson() => {
    'posizione': posizione,
    'contatti': contatti,
    'notificheSistema': notificheSistema,
    'bluetooth': bluetooth,
  };

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  factory Permesso.fromJson(Map<String, dynamic> json) {
    return Permesso(
      posizione: json['posizione'] ?? false,
      contatti: json['contatti'] ?? false,
      notificheSistema: json['notificheSistema'] ?? false,
      bluetooth: json['bluetooth'] ?? false,
    );
  }
}