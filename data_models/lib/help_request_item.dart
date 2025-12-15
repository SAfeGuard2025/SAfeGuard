// Modello: HelpRequestItem
// Usato per visualizzare in una lista compatta le informazioni chiave di una richiesta di aiuto.
// Non è l'oggetto completo della richiesta, ma una sua "preview".

class HelpRequestItem {
  final String title;
  final String time;
  final String status;
  final bool isComplete;
  final String type; // es. "ambulance", "earthquake", "fire"

  HelpRequestItem({
    required this.title,
    required this.time,
    required this.status,
    required this.isComplete,
    required this.type,
  });
}
