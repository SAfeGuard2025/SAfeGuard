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

  // Nota: In un modello di dati puramente visuale come questo, non sono necessari i metodi toJson/fromJson,
  // poiché il dato grezzo verrebbe mappato in questo oggetto direttamente dal Controller/Service.
}