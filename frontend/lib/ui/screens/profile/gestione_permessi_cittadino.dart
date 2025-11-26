import 'package:flutter/material.dart';
import 'package:data_models/setting_item.dart';
import '../home/home_page_content.dart';
import '../medical/gestione_cartella_clinica_cittadino.dart';
import 'package:frontend/ui/screens/profile/profile_settings_screen.dart';
import 'package:frontend/ui/widgets/custom_bottom_nav_bar.dart';

class GestionePermessiCittadino extends StatefulWidget {
  const GestionePermessiCittadino({super.key});

  @override
  State<GestionePermessiCittadino> createState() =>
      _GestionePermessiCittadinoState();
}

class _GestionePermessiCittadinoState extends State<GestionePermessiCittadino> {
  int _currentIndex = 3;

  // Colori definiti a livello di classe
  final Color bgColor = const Color(0xFF12345A);
  final Color cardColor = const Color(0xFF0E2A48);
  final Color activeColor = const Color(
    0xFFEF923D,
  ); // Arancione coerente con il tema

  final List<SettingItem> permissions = [
    SettingItem(title: 'Accesso alla posizione', isEnabled: false),
    SettingItem(title: 'Accesso ai contatti', isEnabled: false),
    SettingItem(title: 'Notifiche di sistema', isEnabled: false),
    SettingItem(title: 'Accesso alla memoria', isEnabled: false),
    SettingItem(title: 'Accesso al Bluetooth', isEnabled: false),
  ];

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // 0. HOME
      const HomePageContent(),

      // 1. UTENTE (Cartella Clinica)
      const GestioneCartellaClinicaCittadino(),

      // 2. MAPPA
      const Center(
        child: Text(
          "Mappa\n(In lavorazione)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),

      // 3. PERMESSI
      _buildPermissionsContent(),

      // 4. IMPOSTAZIONI
      const ProfileSettingsScreen(isSoccorritore: false),
    ];
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        onIconTapped: _onTabChange,
        // selectedIndex: _currentIndex, // Decommenta se la tua NavBar supporta l'evidenziazione
      ),
    );
  }

  // --- CONTENUTO SPECIFICO DELLA PAGINA PERMESSI ---
  Widget _buildPermissionsContent() {
    return Column(
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  // torno alla pagina delle impostazioni
                  _onTabChange(4);
                },
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.verified_user,
                color: Colors.blueAccent,
                size: 40,
              ),
              const SizedBox(width: 10),
              const Text(
                "Gestione\nPermessi",
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

        // LISTA
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.separated(
                itemCount: permissions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return _buildSwitchItem(permissions[index], activeColor);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Widget helper per la singola riga
  Widget _buildSwitchItem(SettingItem item, Color activeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Switch(
          value: item.isEnabled,
          onChanged: (val) {
            setState(() {
              item.isEnabled = val;
            });
            // PermissionService.update(item.title, val);
          },
          activeThumbColor: activeColor,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade400,
        ),
      ],
    );
  }
}
