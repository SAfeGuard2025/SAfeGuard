///  Modello Base Entità con Serializzazione Automatica (json_serializable)
///
/// Questa classe funge da modello base per tutti gli utenti (Utente, Soccorritore, ecc.)
/// e gestisce la serializzazione (toJson) e la deserializzazione (fromJson)
/// tramite la libreria `json_serializable`.
///
/// ---
///
///  Sicurezza e Gestione della Password (Hash):
///
/// Per garantire che le credenziali non siano esposte al Frontend (sicurezza zero-trust):
///
/// 1.  **Campo Privato/Nullable:** Il campo `_passwordHash` è dichiarato `final String?`
///     ed è mantenuto **privato**. Memorizza l'hash crittografico della password (non il valore in chiaro),
///     che viene gestito e calcolato esclusivamente dal Backend.
///
/// 2.  **Esclusione dalla Deserializzazione (fromJson):** La proprietà `passwordHash` è contrassegnata con:
///     `@JsonKey(ignore: true) String? get passwordHash => _passwordHash;`.
///     Questo **impedisce a json_serializable di includere o richiedere il valore dell'hash**
///     quando l'oggetto Utente viene ricevuto come risposta JSON dal Backend (es. dopo il login).
///
/// 3.  Costruttore Principale: Il parametro `passwordHash` è reso **NOMINATO** (`String? passwordHash`)
///     nel costruttore principale. Questo è necessario per risolvere il conflitto:
///     `json_serializable` ignora il campo durante la lettura JSON ma necessita che il parametro esista
///     nel costruttore principale affinché tutti i campi `final` possano essere inizializzati.
///
/// ---
///
///  Regole per Sottoclassi e Generazione Codice:
///
/// Annotazioni: La classe deve avere l'annotazione `@JsonSerializable(explicitToJson: true)` e la dichiarazione `part '[NomeClasse].g.dart';`.
/// Costruttori: Tutte le sottoclassi (`Utente`, `Soccorritore`) devono implementare un **costruttore non nominato** che accetti tutti i campi (`id`, `email`, `passwordHash`, ecc.) e li inoltri correttamente al costruttore `super()`:
///     L'ID (`id`) è posizionale e pubblico (`this.id`).
///     I campi di login (es. `passwordHash`) sono passati come **argomenti nominati** nel `super()`.
///
/// Reindirizzamento (Errori come "field initializer"):** I costruttori nominati utilizzati per l'inizializzazione specifica (es. `Utente.conEmail`) devono solo reindirizzare a un altro costruttore (`: this(...)`) e **non possono** usare inizializzatori di campo (`this.campo`).
///
import 'package:json_annotation/json_annotation.dart';

part 'utenteGenerico.g.dart';

@JsonSerializable(explicitToJson: true)
class UtenteGenerico {
  final String? _email;
  final String? _telefono;

  final String? _passwordHash;

  final String? nome;
  final String? cognome;
  final DateTime? dataDiNascita;
  final String? cittaDiNascita;
  final String? iconaProfilo;

  //Costruttore principale NON NOMINATO.
  UtenteGenerico({
    String? passwordHash,
    String? email,
    String? telefono,
    this.nome,
    this.cognome,
    this.dataDiNascita,
    this.cittaDiNascita,
    this.iconaProfilo,
  }) : _passwordHash = passwordHash,
       _email = email,
       _telefono = telefono,
       assert(
         email != null || telefono != null,
         'Devi fornire almeno email o telefono per UtenteGenerico',
       );

  // Costruttore 1: Autenticazione tramite Email
  UtenteGenerico.conEmail(
    String email,
    String passwordHash, {
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : this(
         passwordHash: passwordHash,
         email: email,
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  // Costruttore 2: Autenticazione tramite Telefono
  UtenteGenerico.conTelefono(
    String telefono,
    String passwordHash, {
    String? email,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
  }) : this(
         passwordHash: passwordHash,
         email: email,
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
       );

  @JsonKey(includeFromJson: false, includeToJson: false)
  String? get passwordHash => _passwordHash;

  factory UtenteGenerico.fromJson(Map<String, dynamic> json) =>
      _$UtenteGenericoFromJson(json);

  Map<String, dynamic> toJson() => _$UtenteGenericoToJson(this);

  String? get email => _email;
  String? get telefono => _telefono;
}
