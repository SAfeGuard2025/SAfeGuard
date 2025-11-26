import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/custom_bottom_nav_bar.dart';

// --- IMPORTA LE TUE PAGINE ---
import 'package:frontend/ui/screens/home/home_page_content.dart';
import 'package:frontend/ui/screens/medical/gestione_cartella_clinica_cittadino.dart';

import '../profile/gestione_notifiche_cittadino.dart';
import '../profile/profile_settings_screen.dart';
// import 'package:frontend/ui/screens/profile/gestione_notifiche_cittadino.dart';
// import 'package:frontend/ui/screens/profile/profile_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // --- SOLUZIONE: RIEMPI I BUCHI CON PLACEHOLDER ---
  // La lista deve avere 5 elementi esatti per corrispondere alle 5 icone.
  final List<Widget> _pages = [
    // 0. HOME (Esiste già)
    const HomePageContent(),

    // 1. UTENTE (Placeholder temporaneo)
    const GestioneCartellaClinicaCittadino(),

    // 2. MAPPA (Placeholder temporaneo)
    const Center(
      child: Text(
        "Mappa\n(In lavorazione)",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),

    // 3. NOTIFICHE (Placeholder temporaneo)
    const GestioneNotificheCittadino(),

    // 4. IMPOSTAZIONI (Placeholder temporaneo)
    const ProfileSettingsScreen(isSoccorritore: false),
  ];

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041528),

      // IndexedStack ora troverà sempre un widget per ogni indice (0-4)
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),

      bottomNavigationBar: CustomBottomNavBar(onIconTapped: _onTabChange),
    );
  }
}
