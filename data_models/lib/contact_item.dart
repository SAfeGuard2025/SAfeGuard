class ContactItem {
  // Uso 'final' perché i dati del modello non dovrebbero cambiare senza crearne uno nuovo
  final String number;
  final String nameAndRole;

  ContactItem({
    required this.number,
    required this.nameAndRole
  });

// Opzionale: In futuro qui aggiungerai fromJson e toJson
// per comunicare con il Backend come da standard[cite: 30].
}