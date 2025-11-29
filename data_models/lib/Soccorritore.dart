// Modello: Soccorritore
// Modello che rappresenta un utente con privilegi speciali di soccorritore,
// ereditando tutti i campi base da UtenteGenerico.

import 'UtenteGenerico.dart';

class Soccorritore extends UtenteGenerico {

  // Costruttore principale non nominato: Delega a 'super' e forza il flag.
  Soccorritore({
    required int id,
    required String email,
    String? passwordHash,
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : super(
    id: id,
    email: email,
    passwordHash: passwordHash ?? '',
    telefono: telefono,
    nome: nome,
    cognome: cognome,
    dataDiNascita: dataDiNascita,
    cittaDiNascita: cittaDiNascita,
    iconaProfilo: iconaProfilo,
    // Punto Chiave: Forza il flag isSoccorritore a true nella classe base.
    isSoccorritore: true,
  );

  // Costruttore nominato
  Soccorritore.conTuttiICampi(
      int id,
      String email,
      String passwordHash, {
        String? telefono,
        String? nome,
        String? cognome,
        DateTime? dataDiNascita,
        String? cittaDiNascita,
        String? iconaProfilo,
      }) : this(
    id: id,
    email: email,
    passwordHash: passwordHash,
    telefono: telefono,
    nome: nome,
    cognome: cognome,
    dataDiNascita: dataDiNascita,
    cittaDiNascita: cittaDiNascita,
    iconaProfilo: iconaProfilo,
  );

  // Metodo copyWith Avanzato
  // Gestisce la creazione di una copia mutata, includendo sia i campi locali
  // che i campi ereditati (richiama il costruttore principale).
  Soccorritore copyWith({
    int? id,
    String? email,
    String? telefono,
    String? passwordHash,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) {
    return Soccorritore(
      id: id ?? this.id!,
      email: email ?? this.email!,
      telefono: telefono ?? this.telefono,
      passwordHash: passwordHash ?? this.passwordHash,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      dataDiNascita: dataDiNascita ?? this.dataDiNascita,
      cittaDiNascita: cittaDiNascita ?? this.cittaDiNascita,
      iconaProfilo: iconaProfilo ?? this.iconaProfilo,
      // isSoccorritore è forzato nel costruttore
    );
  }

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  factory Soccorritore.fromJson(Map<String, dynamic> json) {
    // Chiama il fromJson del Super (UtenteGenerico) per popolare i campi ereditati
    final utenteGenerico = UtenteGenerico.fromJson(json);

    return Soccorritore(
      id: utenteGenerico.id ?? 0, // Gestione null safety per l'ID
      email: utenteGenerico.email!, // Email è obbligatoria per Soccorritore
      passwordHash: utenteGenerico.passwordHash,
      telefono: utenteGenerico.telefono,
      nome: utenteGenerico.nome,
      cognome: utenteGenerico.cognome,
      dataDiNascita: utenteGenerico.dataDiNascita,
      cittaDiNascita: utenteGenerico.cittaDiNascita,
      iconaProfilo: utenteGenerico.iconaProfilo,
      // isSoccorritore non è passato qui perché è gestito dal costruttore Soccorritore() che chiama super.
    );
  }

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  @override
  Map<String, dynamic> toJson() {
    // Unisce la mappa del Super con i campi propri di Soccorritore
    return super.toJson()..addAll({'id': id});
  }
}