import 'package:json_annotation/json_annotation.dart';
import 'utenteGenerico.dart';

part 'utente.g.dart';

@JsonSerializable(explicitToJson: true)
class Utente extends UtenteGenerico {
  final int id;

  // Costruttore principale NON NOMINATO per json_serializable.
  Utente(
    this.id, {
    String? passwordHash,
    String? email,
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : super(
         passwordHash:
             passwordHash, // Passato al super costruttore UtenteGenerico
         email: email,
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  // Costruttore 1: Autenticazione tramite Email (conferma la presenza di email)
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
  }) : this(
         id,
         passwordHash: passwordHash,
         email: email, // Email è obbligatoria qui
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  //Costruttore 2: Autenticazione tramite Telefono (conferma la presenza di telefono)
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
  }) : this(
         id,
         passwordHash: passwordHash,
         email: email,
         telefono: telefono, // Telefono è obbligatorio qui
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  factory Utente.fromJson(Map<String, dynamic> json) => _$UtenteFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UtenteToJson(this);
}
