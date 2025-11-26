import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/profile/profile_settings_screen.dart';
import '../home/home_page_content.dart';
import '../medical/gestione_cartella_clinica_cittadino.dart';
import 'package:frontend/ui/widgets/custom_bottom_nav_bar.dart';

class GestioneNotificheCittadino extends StatefulWidget {
  const GestioneNotificheCittadino({super.key});

  @override
  State<GestioneNotificheCittadino> createState() =>
      _GestioneNotificheCittadinoState();
}

class _GestioneNotificheCittadinoState
    extends State<GestioneNotificheCittadino> {
  // Variabile di stato per l'indice corrente
  int _currentIndex = 3;

  // Definiamo i colori qui per riutilizzarli
  final Color bgColor = const Color(0xFF12345A);
  final Color cardColor = const Color(0xFF0E2A48);
  final Color accentColor = const Color(0xFFEF923D);

  // Lista delle pagine
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // 0. HOME
      const HomePageContent(),

      // 1. UTENTE
      const GestioneCartellaClinicaCittadino(),

      // 2. MAPPA
      const Center(
        child: Text(
          "Mappa\n(In lavorazione)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),

      // 3. NOTIFICHE
      _buildNotificationContent(),

      // 4. IMPOSTAZIONI
      const ProfileSettingsScreen(isSoccorritore: false),
    ];
  }

  // Funzione per cambiare tab
  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // Uso IndexedStack per mantenere lo stato delle pagine
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),

      bottomNavigationBar: CustomBottomNavBar(onIconTapped: _onTabChange),
    );
  }

  // Schermata delle notifiche
  Widget _buildNotificationContent() {
    return Column(
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              // Implementazione tasto indietro
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  _onTabChange(4);
                },
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.notifications,
                color: Color(0xFFE3C63D),
                size: 40,
              ),
              const SizedBox(width: 10),
              const Text(
                "Gestione\nNotifiche",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),

        // CARD IMPOSTAZIONI
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  _NotificationSwitch(
                    title: 'Notifiche push',
                    initialValue: true,
                    activeColor: accentColor,
                  ),
                  _NotificationSwitch(
                    title: 'Notifiche SMS',
                    initialValue: false,
                    activeColor: accentColor,
                  ),
                  _NotificationSwitch(
                    title: 'Notifiche e-mail',
                    initialValue: true,
                    activeColor: accentColor,
                  ),
                  _NotificationSwitch(
                    title: 'Aggiornamenti',
                    initialValue: false,
                    activeColor: accentColor,
                  ),
                  _NotificationSwitch(
                    title: 'Silenzia notifiche',
                    initialValue: false,
                    activeColor: accentColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// --- WIDGET INTERNO PER LO SWITCH ---
class _NotificationSwitch extends StatefulWidget {
  final String title;
  final bool initialValue;
  final Color activeColor;

  const _NotificationSwitch({
    required this.title,
    required this.initialValue,
    required this.activeColor,
  });

  @override
  State<_NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<_NotificationSwitch> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (val) => setState(() => _isEnabled = val),
            activeThumbColor: widget.activeColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
