// Modello: Condizione
// Gestisce lo stato delle disabilità nel profilo utente.
// Usato principalmente nella schermata "Condizioni Fisiche".

class Condizione {
  final bool disabilitaMotorie;
  final bool disabilitaVisive;
  final bool disabilitaUditive;
  final bool disabilitaIntellettive;
  final bool disabilitaPsichiche;

  // Costruttore con valori di default a 'false'.
  // Questo previene errori null pointer se l'utente è appena stato creato e non ha ancora compilato il profilo.
  Condizione({
    this.disabilitaMotorie = false,
    this.disabilitaVisive = false,
    this.disabilitaUditive = false,
    this.disabilitaIntellettive = false,
    this.disabilitaPsichiche = false,
  });

  // Metodo copyWith: Fondamentale per la UI Flutter (Switch/Checkbox).
  // Permette di creare una nuova istanza dell'oggetto, modificando solo i campi specificati
  // mantenendo gli altri invariati.
  Condizione copyWith({
    bool? disabilitaMotorie,
    bool? disabilitaVisive,
    bool? disabilitaUditive,
    bool? disabilitaIntellettive,
    bool? disabilitaPsichiche,
  }) {
    return Condizione(
      // Se il parametro è nullo (non è stato fornito), usa il valore corrente
      disabilitaMotorie: disabilitaMotorie ?? this.disabilitaMotorie,
      disabilitaVisive: disabilitaVisive ?? this.disabilitaVisive,
      disabilitaUditive: disabilitaUditive ?? this.disabilitaUditive,
      disabilitaIntellettive: disabilitaIntellettive ?? this.disabilitaIntellettive,
      disabilitaPsichiche: disabilitaPsichiche ?? this.disabilitaPsichiche,
    );
  }

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  // Questo formato è quello richiesto dal Repository per il salvataggio nel database.
  Map<String, dynamic> toJson() => {
    'disabilitaMotorie': disabilitaMotorie,
    'disabilitaVisive': disabilitaVisive,
    'disabilitaUditive': disabilitaUditive,
    'disabilitaIntellettive': disabilitaIntellettive,
    'disabilitaPsichiche': disabilitaPsichiche,
  };

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  // Viene usato dal ProfileService per convertire i dati grezzi del DB in un oggetto Dart tipizzato.
  factory Condizione.fromJson(Map<String, dynamic> json) {
    return Condizione(
      // Usa '?? false' per garantire robustezza.
      disabilitaMotorie: json['disabilitaMotorie'] ?? false,
      disabilitaVisive: json['disabilitaVisive'] ?? false,
      disabilitaUditive: json['disabilitaUditive'] ?? false,
      disabilitaIntellettive: json['disabilitaIntellettive'] ?? false,
      disabilitaPsichiche: json['disabilitaPsichiche'] ?? false,
    );
  }
}