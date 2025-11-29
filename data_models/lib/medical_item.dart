// Modello: MedicalItem
// Classe base per elementi di natura medica (es. Allergia, Farmaco) da usare in una lista.

class MedicalItem {
  final String name;

  MedicalItem({
    required this.name,
  });

  // Metodo copyWith: Fondamentale per la UI Flutter (Switch/Checkbox).
  // Permette di creare una nuova istanza dell'oggetto, modificando solo i campi specificati
  // mantenendo gli altri invariati.
  MedicalItem copyWith({String? name}) {
    return MedicalItem(
      name: name ?? this.name,
    );
  }
}