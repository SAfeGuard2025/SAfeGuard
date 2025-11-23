// ** File: lib/data_models/Utente.dart ** (Manuale)

import 'UtenteGenerico.dart';

// Rimosse le importazioni e le annotazioni di json_serializable

class Utente extends UtenteGenerico {
  final int id;

  // Costruttore principale NON NOMINATO
  Utente({
    required this.id,
    String? passwordHash,
    String? email,
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : super(
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
    this.id,
    String email,
    String passwordHash, {
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : super.conEmail(
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
    this.id,
    String telefono,
    String passwordHash, {
    String? email,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : super.conTelefono(
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
      id: json['id'] as int,
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
