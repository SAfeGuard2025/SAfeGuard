import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/custom_bottom_nav_bar.dart';

import 'package:frontend/ui/screens/home/home_page_content.dart';
import 'package:frontend/ui/screens/medical/gestione_cartella_clinica_cittadino.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
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

    // 3. AVVISI (Placeholder temporaneo)
    const Center(
      child: Text(
        "Avvisi\nin lavorazione",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),

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
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    return Scaffold(
      //Decide il colore a seconda di se sta visualizzando
      //un soccorritore o un utente
      backgroundColor: Color(isRescuer?0xFFef923d:0xFF0e2a48),


      // IndexedStack trova sempre un widget per ogni indice (0-4)
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),

      bottomNavigationBar: CustomBottomNavBar(onIconTapped: _onTabChange),
    );
  }
}
