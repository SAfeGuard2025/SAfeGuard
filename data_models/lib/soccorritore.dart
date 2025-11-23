import 'package:json_annotation/json_annotation.dart';
import 'utenteGenerico.dart';

part 'soccorritore.g.dart';

@JsonSerializable(explicitToJson: true)
class Soccorritore extends UtenteGenerico {
  final int id;

  // Costruttore principale NON NOMINATO per json_serializable.
  Soccorritore(
    this.id,
    String email, { // Email obbligatoria (posizionale)
    String? passwordHash,
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

  // Costruttore effettivo adattato per chiamare il costruttore principale
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
         id,
         email,
         passwordHash: passwordHash,
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  factory Soccorritore.fromJson(Map<String, dynamic> json) =>
      _$SoccorritoreFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SoccorritoreToJson(this);
}
