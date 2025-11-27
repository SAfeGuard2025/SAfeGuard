// ** File: lib/data_models/UtenteGenerico.dart ** (Manuale)

class UtenteGenerico {
  final int? id;
  final String? email;
  final String? telefono;
  final String? passwordHash;

  final String? nome;
  final String? cognome;
  final DateTime? dataDiNascita;
  final String? cittaDiNascita;
  final String? iconaProfilo;

  // NUOVO CAMPO BOOLEANO
  final bool isSoccorritore;

  // Costruttore principale
  UtenteGenerico({
    this.id,
    this.email,
    this.telefono,
    required this.passwordHash,
    this.nome,
    this.cognome,
    this.dataDiNascita,
    this.cittaDiNascita,
    this.iconaProfilo,
    this.isSoccorritore = false, // Default: Utente normale (false)
  }) : assert(
  email != null || telefono != null,
  'Devi fornire almeno email o telefono per UtenteGenerico',
  );

  // Costruttore 1: Autenticazione tramite Email
  UtenteGenerico.conEmail(
      int? id,
      String email,
      String passwordHash, {
        String? telefono,
        String? nome,
        String? cognome,
        DateTime? dataDiNascita,
        String? cittaDiNascita,
        String? iconaProfilo,
        bool isSoccorritore = false, // Parametro opzionale
      }) : this(
    id: id,
    passwordHash: passwordHash,
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
      String passwordHash, {
        String? email,
        String? nome,
        String? cognome,
        DateTime? dataDiNascita,
        String? cittaDiNascita,
        String? iconaProfilo,
        bool isSoccorritore = false, // Parametro opzionale
      }) : this(
    id: id,
    passwordHash: passwordHash,
    email: email,
    telefono: telefono,
    nome: nome,
    cognome: cognome,
    dataDiNascita: dataDiNascita,
    cittaDiNascita: cittaDiNascita,
    iconaProfilo: iconaProfilo,
    isSoccorritore: isSoccorritore,
  );

  // DESERIALIZZAZIONE (JSON -> Oggetto)
  factory UtenteGenerico.fromJson(Map<String, dynamic> json) {
    return UtenteGenerico(
      id: json['id'] as int?,
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
      passwordHash: json['passwordHash'] as String? ?? 'HASH_NON_RICEVUTO',
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

  // SERIALIZZAZIONE (Oggetto -> JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'telefono': telefono,
      'passwordHash': passwordHash,
      'nome': nome,
      'cognome': cognome,
      'dataDiNascita': dataDiNascita?.toIso8601String(),
      'cittaDiNascita': cittaDiNascita,
      'iconaProfilo': iconaProfilo,
      'isSoccorritore': isSoccorritore, // Salva il booleano
    };
  }
}