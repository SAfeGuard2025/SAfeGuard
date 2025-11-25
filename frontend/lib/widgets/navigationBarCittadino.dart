import 'package:flutter/material.dart';

// Funzione per convertire la stringa Hex (senza alpha) in un oggetto Color.
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode"; // Add Alpha 255 (opacità massima)
  }
  return Color(int.parse(hexCode, radix: 16));
}

// CONVERTITO IN STATEFULWIDGET per gestire l'indice selezionato e il feedback visivo
class CustomBottomNavBar extends StatefulWidget {
  // Parametro obbligatorio per comunicare l'indice toccato al widget genitore (HomePage)
  final Function(int) onIconTapped;

  const CustomBottomNavBar({
    super.key,
    required this.onIconTapped, // Ritorna il parametro onIconTapped
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  // imposto il colore dello sfondo
  final Color mainBackgroundColor = hexToColor("16273f");
  // Colore per le icone non selezionate
  final Color unselectedIconColor = Colors.white;
  // Colore per l'icona selezionata (per dare feedback visivo)
  final Color selectedIconColor = hexToColor(
    "FF9800",
  ); // AmberOrange, colore usato nel mockup

  // Lista delle icone
  List<IconData> navIcons = [
    Icons.home,
    Icons.medication_liquid_sharp,
    Icons.map,
    Icons.notifications,
    Icons.settings,
  ];

  // Stato: Mi salvo l'indice di quello selezionato (inizialmente 0)
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      // impostazioni di altezza e margini (effetto "fluttuante")
      height: 65,
      margin: const EdgeInsets.only(right: 24, left: 24, bottom: 15),
      // Decorazioni
      decoration: BoxDecoration(
        color: mainBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hexToColor("3F3F46")),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        // Mappiamo le icone usando l'indice per la gestione dello stato
        children: navIcons.asMap().entries.map((entry) {
          final int index = entry.key;
          final IconData iconData = entry.value;

          // Determina il colore: selectedIconColor se l'indice corrisponde, altrimenti unselectedIconColor
          final Color iconColor = index == selectedIndex
              ? selectedIconColor
              : unselectedIconColor.withOpacity(0.7);

          return InkWell(
            onTap: () {
              // 1. Aggiorna lo stato locale del widget per cambiare il colore
              setState(() {
                selectedIndex = index;
              });
              // 2. Chiama la funzione esterna (onIconTapped) per dire alla HomePage di cambiare body
              widget.onIconTapped(index);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, color: iconColor, size: 30),
                  // Indicatore visivo opzionale (il pallino sotto l'icona selezionata)
                  if (index == selectedIndex)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 4,
                      width: 4,
                      decoration: BoxDecoration(
                        color: selectedIconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

// Rimosso il metodo _navigateToScreen in quanto la navigazione è gestita dal parent widget (HomePage)
}
