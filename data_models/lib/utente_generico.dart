// Modello: UtenteGenerico
// Classe base che definisce i campi anagrafici e di autenticazione comuni
// a tutti gli utenti del sistema (cittadini normali e soccorritori).

class UtenteGenerico {
  final int? id;
  final String? email;
  final String? telefono;
  final String? passwordHash;
  final String? tokenFCM;

  final String? nome;
  final String? cognome;
  final DateTime? dataDiNascita;
  final String? cittaDiNascita;
  final String? iconaProfilo;

  final bool isSoccorritore;

  // Costruttore principale
  // Usato internamente e come target per i costruttori nominati e il fromJson.
  UtenteGenerico({
    this.id,
    this.email,
    this.telefono,
    required this.passwordHash,
    this.tokenFCM,
    this.nome,
    this.cognome,
    this.dataDiNascita,
    this.cittaDiNascita,
    this.iconaProfilo,
    this.isSoccorritore = false,
  }) : assert(
         email != null || telefono != null,
         'Devi fornire almeno email o telefono per UtenteGenerico',
       );

  // Costruttore 1: Autenticazione tramite Email
  UtenteGenerico.conEmail(
    int? id,
    String email,
    String passwordHash, {
    String? tokenFCM,
    String? telefono,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
    bool isSoccorritore = false,
  }) : this(
         // Delega al costruttore principale
         id: id,
         passwordHash: passwordHash,
         tokenFCM: tokenFCM,
         email: email,
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
         isSoccorritore: isSoccorritore,
       );

  // Costruttore 2: Autenticazione tramite Telefono
  UtenteGenerico.conTelefono(
    int? id,
    String telefono,
    String passwordHash,{
    String? tokenFCM,
    String? email,
    String? nome,
    String? cognome,
    DateTime? dataDiNascita,
    String? cittaDiNascita,
    String? iconaProfilo,
    bool isSoccorritore = false,
  }) : this(
         // Delega al costruttore principale
         id: id,
         passwordHash: passwordHash,
         tokenFCM: tokenFCM,
         email: email,
         telefono: telefono,
         nome: nome,
         cognome: cognome,
         dataDiNascita: dataDiNascita,
         cittaDiNascita: cittaDiNascita,
         iconaProfilo: iconaProfilo,
         isSoccorritore: isSoccorritore,
       );

  // Deserializzazione (da JSON a Model): Factory per ricostruire l'oggetto da una Map JSON.
  factory UtenteGenerico.fromJson(Map<String, dynamic> json) {
    return UtenteGenerico(
      id: json['id'] as int?,
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
      // Se 'passwordHash' manca, usa un fallback
      passwordHash: json['passwordHash'] as String? ?? 'HASH_NON_RICEVUTO',
      tokenFCM: json['tokenFCM'] as String?,
      nome: json['nome'] as String?,
      cognome: json['cognome'] as String?,
      dataDiNascita: json['dataDiNascita'] != null
          ? DateTime.parse(json['dataDiNascita'])
          : null,
      cittaDiNascita: json['cittaDiNascita'] as String?,
      iconaProfilo: json['iconaProfilo'] as String?,
      // Lettura del booleano, default false se manca
      isSoccorritore: json['isSoccorritore'] as bool? ?? false,
    );
  }

  // Serializzazione (Da Model a JSON): Converte l'oggetto in una Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telefono': telefono,
      'passwordHash': passwordHash,
      'tokenFCM': tokenFCM,
      'nome': nome,
      'cognome': cognome,
      'dataDiNascita': dataDiNascita?.toIso8601String(),
      'cittaDiNascita': cittaDiNascita,
      'iconaProfilo': iconaProfilo,
      'isSoccorritore': isSoccorritore,
    };
  }
}
