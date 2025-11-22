class User {
  final int id;
  final String name;
  final String email;

  // Costruttore principale per creare un oggetto User
  User({required this.id, required this.name, required this.email});

  // --- DESERIALIZZAZIONE (JSON -> OGGETTO Dart) ---
  // Factory constructor utilizzato dal Front-end per convertire la Map (ottenuta dal JSON) in un oggetto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  // --- SERIALIZZAZIONE (OGGETTO Dart -> JSON) ---
  // Metodo utilizzato dal Back-end per convertire l'oggetto User in una Map<String, dynamic>
  // che sarà poi codificata in una stringa JSON prima di essere inviata.
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
