import 'package:flutter/material.dart';

// Funzione per convertire la stringa Hex (senza alpha) in un oggetto Color.
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode"; // Aggiunge Alpha 255 (opacità massima)
  }
  return Color(int.parse(hexCode, radix: 16));
}

class CustomBottomNavBar extends StatelessWidget {
  CustomBottomNavBar({super.key});

  // imposto il colore delLo sfondo
  final Color mainBackgroundColor = hexToColor("16273f");
  // imposto il colore che voglio dare alle icone
  final Color iconsColor = Colors.white;

  // Mi metto in una lista le icone da utilizzare e in un'altra lista il titolo di quelle "sezioni"
  List<IconData> navIcons = [
    Icons.home,
    Icons.medication_liquid_sharp,
    Icons.map,
    Icons.notifications,
    Icons.settings,
  ];
  // Mi salvo i titoli delle icone
  List<String> navTitle = ["Home", "Utente", "Mappa", "Avvisi", "Impostazioni"];
  // Mi salvo l'indice di quello selezionato (di base sarà 0 visto che è la schermata principale)
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      // impostazioni di altezza e margini
      height: 65,
      margin: const EdgeInsets.only(right: 24, left: 24, bottom: 24),
      // Decorazioni
      decoration: BoxDecoration(
        // assegno il colore che ho definito alla riga 15
        color: this.mainBackgroundColor,
        // dò il border radius di valore 16 (come era nei mockup)
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hexToColor("3F3F46")),
      ),

      child: Row(
        // allineo le icone al centro rispetto all'asse Y
        crossAxisAlignment: CrossAxisAlignment.center,
        // distanzio le icone tra di loro
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        // metto le icone tramite tramite iterazione
        children: navIcons.map((iconData) {
          // metto ogni volta la singola icona in iconData
          /*return Icon(
            // definisco il valore (iconData)
            iconData,
            // dò il colore che ho definito per le icone
            color: iconsColor,
            // scelgo la dimensione (Nei mockup width = 30 e height = 30, suppongo sia 30 anche qui)
            size: 30,
          );
           */
          return InkWell(
            onTap: () {
              // passiamo l'icona che abbiamo premuto alla funzione che fara il dispatch per la schermata richiesta
              _navigateToScreen(iconData, navIcons, context);
            },
            child: Icon(
              // definisco il valore (iconData)
              iconData,
              // dò il colore che ho definito per le icone
              color: iconsColor,
              // scelgo la dimensione (Nei mockup width = 30 e height = 30, suppongo sia 30 anche qui)
              size: 30,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToScreen(
    IconData icon,
    List<IconData> navIcons,
    BuildContext context,
  ) {
    /*Widget screen = const Home(); // di base va alla home, se non c'è sta riga dà errore il compilatore

    if(icon == navIcons.elementAt(0)){
      screen = const Home(); // nome della classe della pagina che vogliamo collegare (Home() è solo un esempio)
    }

    if(icon == navIcons.elementAt(0)){

    }

    if(icon == navIcons.elementAt(0)){

    }

    if(icon == navIcons.elementAt(0)){

    }



    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => screen,
        )
    );

     */
  }
}
