// Modello: Utente
// Rappresenta l'utente base del sistema. Eredita i campi anagrafici da UtenteGenerico
// e aggiunge i dati specifici del profilo (permessi, liste mediche, ecc.).

import 'utente_generico.dart';
import 'permesso.dart';
import 'condizione.dart';
import 'notifica.dart';
import 'contatto_emergenza.dart';

class Utente extends UtenteGenerico {
  // Oggetti Modello Nidificati
  final Permesso permessi;
  final Condizione condizioni;
  final Notifica notifiche;

  final List<String> allergie;
  final List<String> medicinali;
  final List<ContattoEmergenza> contattiEmergenza;

  // Costruttore Unificato
  Utente({
    // Campi ereditati da UtenteGenerico
    required int super.id,
    super.passwordHash,
    super.email,
    super.telefono,
    super.nome,
    super.cognome,
    super.dataDiNascita,
    super.cittaDiNascita,
    super.iconaProfilo,

    // Campi specifici (Opzionali per deserializzazione)
    Permesso? permessi,
    Condizione? condizioni,
    Notifica? notifiche,
    List<String>? allergie,
    List<String>? medicinali,
    List<ContattoEmergenza>? contattiEmergenza,
  }) : // Inizializzazione Sicura dei campi specifici:
       // Se gli oggetti (Permesso, Condizione, Notifica) arrivano null dal DB,
       // vengono inizializzati con le loro rispettive classi di default
       permessi = permessi ?? Permesso(),
       condizioni = condizioni ?? Condizione(),
       notifiche = notifiche ?? Notifica(),
       allergie = allergie ?? const [],
       medicinali = medicinali ?? const [],
       contattiEmergenza = contattiEmergenza ?? const [];

  // Metodo copyWith Avanzato
  // Gestisce la creazione di una copia mutata, includendo sia i campi locali
  // che i campi ereditati (richiama il costruttore principale).
  Utente copyWith({
    int? id,
    String? email,
    String? telefono,
    String? passwordHash,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
    Permesso? permessi,
    Condizione? condizioni,
    Notifica? notifiche,
    List<String>? allergie,
    List<String>? medicinali,
    List<ContattoEmergenza>? contattiEmergenza,
  }) {
    return Utente(
      // Campi ereditati (usa i valori correnti se non forniti)
      id: id ?? this.id!,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      passwordHash: passwordHash ?? this.passwordHash,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      dataDiNascita: dataDiNascita ?? this.dataDiNascita,
      cittaDiNascita: cittaDiNascita ?? this.cittaDiNascita,
      iconaProfilo: iconaProfilo ?? this.iconaProfilo,

      // Campi locali (usa i valori correnti se non forniti)
      permessi: permessi ?? this.permessi,
      condizioni: condizioni ?? this.condizioni,
      notifiche: notifiche ?? this.notifiche,
      allergie: allergie ?? this.allergie,
      medicinali: medicinali ?? this.medicinali,
      contattiEmergenza: contattiEmergenza ?? this.contattiEmergenza,
    );
  }

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  factory Utente.fromJson(Map<String, dynamic> json) {
    // 1. Chiama il fromJson del Super (UtenteGenerico) per popolare i campi ereditati
    final utenteGenerico = UtenteGenerico.fromJson(json);

    // 2. Costruisce l'Utente finale
    return Utente(
      // Popola i campi ereditati
      id: utenteGenerico.id!,
      passwordHash: utenteGenerico.passwordHash,
      email: utenteGenerico.email,
      telefono: utenteGenerico.telefono,
      nome: utenteGenerico.nome,
      cognome: utenteGenerico.cognome,
      dataDiNascita: utenteGenerico.dataDiNascita,
      cittaDiNascita: utenteGenerico.cittaDiNascita,
      iconaProfilo: utenteGenerico.iconaProfilo,

      // 3. Parsing oggetti nidificati
      permessi: json['permessi'] != null
          ? Permesso.fromJson(json['permessi'])
          : Permesso(),
      condizioni: json['condizioni'] != null
          ? Condizione.fromJson(json['condizioni'])
          : Condizione(),
      notifiche: json['notifiche'] != null
          ? Notifica.fromJson(json['notifiche'])
          : Notifica(),

      // 4. Parsing Liste
      allergie:
          (json['allergie'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      medicinali:
          (json['medicinali'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contattiEmergenza:
          (json['contattiEmergenza'] as List<dynamic>?)
              ?.map((e) => ContattoEmergenza.fromJson(e))
              .toList() ??
          [],
    );
  }

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  @override
  Map<String, dynamic> toJson() {
    // 1. Ottiene i dati ereditati da UtenteGenerico
    final Map<String, dynamic> data = super.toJson();

    // 2. Aggiunge i dati specifici di Utente
    data.addAll({
      'id': id,
      'permessi': permessi.toJson(),
      'condizioni': condizioni.toJson(),
      'notifiche': notifiche.toJson(),
      'allergie': allergie,
      'medicinali': medicinali,
      'contattiEmergenza': contattiEmergenza.map((c) => c.toJson()).toList(),
    });

    return data;
  }
}
