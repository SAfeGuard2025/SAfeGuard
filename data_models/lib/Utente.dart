// ** File: lib/data_models/Utente.dart ** (Manuale)

import 'UtenteGenerico.dart';

// Rimosse le importazioni e le annotazioni di json_serializable

class Utente extends UtenteGenerico {

  // Costruttore principale NON NOMINATO
  Utente({
    required int id,
    String? passwordHash,
    String? email,
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : super(
          id: id,
         passwordHash: passwordHash,
         email: email,
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  // Costruttore 1: Autenticazione tramite Email
  Utente.conEmail(
    int id,
    String email,
    String passwordHash, {
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : super.conEmail(
          id,
         email,
         passwordHash,
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  // Costruttore 2: Autenticazione tramite Telefono
  Utente.conTelefono(
    int id,
    String telefono,
    String passwordHash, {
    String? email,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : super.conTelefono(
          id,
         telefono,
         passwordHash,
         email: email,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  // DESERIALIZZAZIONE MANUALE (Gestisce il Super)
  factory Utente.fromJson(Map<String, dynamic> json) {
    // Chiama il fromJson del Super (UtenteGenerico) per popolare i campi ereditati
    final utenteGenerico = UtenteGenerico.fromJson(json);

    return Utente(
      id: utenteGenerico.id!,
      passwordHash: utenteGenerico.passwordHash,
      email: utenteGenerico.email,
      telefono: utenteGenerico.telefono,
      nome: utenteGenerico.nome,
      cognome: utenteGenerico.cognome,
      dataDiNascita: utenteGenerico.dataDiNascita,
      cittaDiNascita: utenteGenerico.cittaDiNascita,
      iconaProfilo: utenteGenerico.iconaProfilo,
    );
  }

  // SERIALIZZAZIONE MANUALE (Gestisce il Super)
  @override
  Map<String, dynamic> toJson() {
    // Unisce la mappa del Super con i campi propri di Utente
    return super.toJson()..addAll({'id': id});
  }

}
