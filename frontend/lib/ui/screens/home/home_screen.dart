import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/custom_bottom_nav_bar.dart';

// --- 1. IMPORTA LE TUE PAGINE QUI ---
// (Assicurati che i percorsi siano giusti in base a dove hai spostato i file)
//import 'package:frontend/ui/screens/home/home_page_content.dart';
//import 'package:frontend/ui/screens/medical/gestione_cartella_clinica_cittadino.dart';
//import 'package:frontend/ui/screens/profile/gestione_notifiche_cittadino.dart';
//import 'package:frontend/ui/screens/profile/profile_settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // --- 2. INSERISCI LE CLASSI NELLA LISTA ---
  // L'ordine DEVE essere lo stesso delle icone nella Navbar:
  // 0: Home, 1: Utente, 2: Mappa, 3: Notifiche, 4: Impostazioni
  final List<Widget> _pages = [
    // Indice 0: La Home (Contenuto centrale coi bottoni SOS)
    //const HomePageContent(),

    // Indice 1: Sezione Medica (Cartella Clinica)
    //const GestioneCartellaClinicaCittadino(),

    // Indice 2: Mappa (Non ho visto il file, lascio un placeholder per ora)
    const Center(
        child: Text("Qui andrà la Mappa", style: TextStyle(color: Colors.white, fontSize: 24))
    ),

    // Indice 3: Notifiche
    //const GestioneNotificheCittadino(),

    // Indice 4: Impostazioni Profilo
    // (Passiamo isSoccorritore: false se è un cittadino)
    //const ProfileSettingsScreen(isSoccorritore: false),
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

      // Usa IndexedStack per mantenere lo stato delle pagine (es. scroll)
      // quando cambi scheda.
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        onIconTapped: _onTabChange,
      ),
    );
  }
}