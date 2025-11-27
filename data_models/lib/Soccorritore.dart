// ** File: lib/data_models/Soccorritore.dart ** (Manuale)

import 'UtenteGenerico.dart';

// Rimosse le importazioni e le annotazioni di json_serializable

class Soccorritore extends UtenteGenerico {

  // Costruttore principale NON NOMINATO
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
    // QUI FORZIAMO A TRUE: Se è un'istanza di Soccorritore, il flag è true.
    isSoccorritore: true,
  );

  // Costruttore nominato: più facile da usare dal codice
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

  // DESERIALIZZAZIONE MANUALE (Gestisce il Super)
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
      // Non serve passare isSoccorritore qui perché il costruttore Soccorritore()
      // lo imposta automaticamente a true chiamando super.
    );
  }

  // SERIALIZZAZIONE MANUALE (Gestisce il Super)
  @override
  Map<String, dynamic> toJson() {
    // Unisce la mappa del Super con i campi propri di Soccorritore
    // Nota: super.toJson() includerà già 'isSoccorritore': true grazie al costruttore.
    return super.toJson()..addAll({'id': id});
  }
}