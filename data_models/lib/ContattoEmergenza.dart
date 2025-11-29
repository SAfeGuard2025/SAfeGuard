// Modello: ContattoEmergenza
// Oggetto semplice e immutabile per gestire gli elementi della lista
// "Contatti di Emergenza" nel profilo utente.

class ContattoEmergenza {
  final String nome;
  final String numero;

  ContattoEmergenza({required this.nome, required this.numero});

  // Metodo copyWith: Fondamentale per la UI Flutter (Switch/Checkbox).
  // Permette di creare una nuova istanza dell'oggetto, modificando solo i campi specificati
  // mantenendo gli altri invariati.
  ContattoEmergenza copyWith({
    String? nome,
    String? numero,
  }) {
    return ContattoEmergenza(
      nome: nome ?? this.nome,
      numero: numero ?? this.numero,
    );
  }

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  // Utilizzato dal ProfileService e UserRepository per salvare i dati nel database.
  Map<String, dynamic> toJson() => {
    'nome': nome,
    'numero': numero,
  };

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  // Utile per caricare i dati dal database nel modello Dart.
  factory ContattoEmergenza.fromJson(Map<String, dynamic> json) {
    return ContattoEmergenza(
      // Usa '?? false' per garantire robustezza.
      nome: json['nome'] ?? '',
      numero: json['numero'] ?? '',
    );
  }
}