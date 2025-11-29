// Modello: Notifica
// Classe immutabile che gestisce tutte le preferenze di notifica dell'utente.

class Notifica {
  final bool push;
  final bool sms;
  final bool silenzia;
  final bool mail;
  final bool aggiornamenti;

  Notifica({
    // I default per canali critici (Push, SMS)
    // per coerenza con lo scope dell sistema software
    this.push = true,
    this.sms = true,
    this.silenzia = false,
    this.mail = true,
    this.aggiornamenti = true,
  });

  // Metodo copyWith: Fondamentale per la UI Flutter (Switch/Checkbox).
  // Permette di creare una nuova istanza dell'oggetto, modificando solo i campi specificati
  // mantenendo gli altri invariati.
  Notifica copyWith({
    bool? push,
    bool? sms,
    bool? silenzia,
    bool? mail,
    bool? aggiornamenti,
  }) {
    return Notifica(
      push: push ?? this.push,
      sms: sms ?? this.sms,
      silenzia: silenzia ?? this.silenzia,
      mail: mail ?? this.mail,
      aggiornamenti: aggiornamenti ?? this.aggiornamenti,
    );
  }

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  Map<String, dynamic> toJson() => {
    'push': push,
    'sms': sms,
    'silenzia': silenzia,
    'mail': mail,
    'aggiornamenti': aggiornamenti,
  };

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  factory Notifica.fromJson(Map<String, dynamic> json) {
    return Notifica(
      // Usa '?? false' per garantire robustezza.
      push: json['push'] ?? true,
      sms: json['sms'] ?? true,
      silenzia: json['silenzia'] ?? false,
      mail: json['mail'] ?? true,
      aggiornamenti: json['aggiornamenti'] ?? true,
    );
  }
}