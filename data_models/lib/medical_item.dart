class MedicalItem {
  final String name;
  // Aggiungo un campo opzionale per il futuro (es. ID dal database)
  // final String? id;

  MedicalItem({
    required this.name,
  });

  // Metodo helper per creare una copia modificata (utile se i campi sono final)
  MedicalItem copyWith({String? name}) {
    return MedicalItem(
      name: name ?? this.name,
    );
  }
}