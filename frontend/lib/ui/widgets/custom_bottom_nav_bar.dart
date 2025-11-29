import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

class CustomBottomNavBar extends StatefulWidget {
  // Funzione di callback: comunica alla Home quale icona è stata premuta
  final Function(int) onIconTapped;

  const CustomBottomNavBar({
    super.key,
    required this.onIconTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final isLogged = context.watch<AuthProvider>().isLogged;
    final Color backgroundColor = isRescuer
        ? ColorPalette.navBarRescuerBackground // Marrone/Arancio (Soccorritore)
        : ColorPalette.navBarUserBackground; // Blu Scuro (Cittadino)

    final Color selectedItemColor = ColorPalette.primaryOrange; // Arancione attivo
    final Color unselectedItemColor = Colors.white;

    // Lista icone
    final List<IconData> navIcons = [

      ?isLogged ? Icons.home_outlined : null,
      ?isLogged ? Icons.report_problem_outlined : null,
      Icons.map_outlined,
      ?isLogged ? Icons.notifications_none : null,
      ?isLogged ? Icons.settings_outlined : null,
    ];

    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    navIcons[index],
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