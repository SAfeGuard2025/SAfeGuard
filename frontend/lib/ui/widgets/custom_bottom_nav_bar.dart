import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  // Funzione di callback: comunica alla Home quale icona è stata premuta
  final Function(int) onIconTapped;

  // Parametro opzionale per cambiare stile se l'utente è un soccorritore
  final bool isSoccorritore;

  const CustomBottomNavBar({
    super.key,
    required this.onIconTapped,
    this.isSoccorritore = false, // Di default è Cittadino (Blu)
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // --- 1. CONFIGURAZIONE STILE IN BASE AL RUOLO ---
    // Colori presi dai tuoi file originali
    final Color backgroundColor = widget.isSoccorritore
        ? const Color(0xFF995618) // Marrone/Arancio (Soccorritore)
        : const Color(0xFF16273F); // Blu Scuro (Cittadino)

    final Color selectedItemColor = const Color(0xFFEF923D); // Arancione attivo
    final Color unselectedItemColor = Colors.white;

    // --- 2. LISTA ICONE ---
    // Cambia l'icona centrale in base al ruolo (Medicina vs Persona)
    final List<IconData> navIcons = [
      Icons.home_outlined,
      widget.isSoccorritore ? Icons.person_outline : Icons.medication_liquid_sharp,
      Icons.map_outlined,
      Icons.notifications_none,
      Icons.settings_outlined,
    ];

    return Container(
      // Altezza e Margini per l'effetto "Fluttuante"
      height: 70,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1), // Bordo sottile
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navIcons.length, (index) {
          final isSelected = _selectedIndex == index;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              // Avvisa la pagina padre (Home) del cambio
              widget.onIconTapped(index);
            },
            // Effetto tocco circolare
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    navIcons[index],
                    // Se selezionato usa l'arancione, altrimenti bianco
                    color: isSelected ? selectedItemColor : unselectedItemColor,
                    size: 28,
                  ),
                  // Pallino indicatore sotto l'icona selezionata
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: selectedItemColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 9), // Spazio vuoto per mantenere l'allineamento
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}