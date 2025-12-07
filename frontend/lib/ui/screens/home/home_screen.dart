import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/reports/emergencies_screen.dart';
import 'package:frontend/ui/widgets/custom_bottom_nav_bar.dart';
import 'package:frontend/ui/screens/home/home_page_content.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import '../profile/profile_settings_screen.dart';
import 'package:frontend/ui/screens/map/map_screen.dart';
import 'package:frontend/ui/screens/reports/reports_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata Principale
// Gestisce la navigazione tra le sezioni dell'app, adattandosi al fattore di forma.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista dei widget/schermate visualizzati
  final List<Widget> _pages = [
    const HomePageContent(), // 0. HOME
    const ReportsScreen(), // 1. REPORT
    const MapScreen(), // 2. MAPPA
    const EmergencyGridPage(),
    const ProfileSettingsScreen(), // 4. IMPOSTAZIONI
  ];

  // Callback per aggiornare l'indice quando viene premuta un'icona
  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Accesso allo stato del ruolo utente per personalizzare i colori
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    // Colori di sfondo e selezione dinamici
    final backgroundColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundDarkBlue;
    final selectedColor = isRescuer
        ? ColorPalette.backgroundDarkBlue
        : ColorPalette.primaryOrange;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Logica per determinare se è un layout desktop/wide
        final bool isDesktop = constraints.maxWidth >= 1100;

        return Scaffold(
          backgroundColor: backgroundColor,
          // Mostra la BottomNavBar solo se NON siamo su desktop
          bottomNavigationBar: isDesktop
              ? null
              : CustomBottomNavBar(onIconTapped: _onTabChange),

          // Usa una Row per affiancare la Sidebar (se c'è) al contenuto principale
          body: Row(
            children: [
              // Barra di navigazione laterale (Visibile solo su Desktop)
              if (isDesktop)
                NavigationRail(
                  backgroundColor: Colors.white,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabChange,
                  labelType: NavigationRailLabelType.all,
                  indicatorColor: selectedColor.withValues(alpha: 0.2),
                  selectedIconTheme: IconThemeData(color: selectedColor),
                  selectedLabelTextStyle: TextStyle(
                    color: selectedColor,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment),
                      label: Text('Report'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map),
                      label: Text('Mappa'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications),
                      label: Text('Avvisi'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profilo'),
                    ),
                  ],
                ),

              // Divisore verticale tra sidebar e contenuto
              if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

              // Contenuto centrale
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _currentIndex == 2 ? double.infinity : 1200,
                      ),
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _pages,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
