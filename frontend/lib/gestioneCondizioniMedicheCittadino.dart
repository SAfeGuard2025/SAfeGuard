import 'package:flutter/material.dart';

// Helper per i colori
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode";
  }
  return Color(int.parse(hexCode, radix: 16));
}

class CondizioniMedicheScreen extends StatefulWidget {
  const CondizioniMedicheScreen({super.key});

  @override
  State<CondizioniMedicheScreen> createState() => _CondizioniMedicheScreenState();
}

class _CondizioniMedicheScreenState extends State<CondizioniMedicheScreen> {
  // Stato degli switch (inizializzati come nello screenshot)
  bool _disabilitaMotorie = true; // Il primo è attivo nello screen
  bool _disabilitaVisive = false;
  bool _disabilitaUditive = false;
  bool _disabilitaIntellettive = false;
  bool _disabilitaPsichiche = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = hexToColor("12345a");
    final Color cardColor = hexToColor("0e2a48");
    final Color navBarColor = hexToColor("0e2a48");
    final Color activeSwitchColor = hexToColor("ef923d"); // Arancione

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Icona e Titolo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder per l'immagine 3D del dottore
                  // Usa: Image.asset("assets/images/doctor_icon.png", height: 80),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_3, color: Colors.white, size: 50),
                  ),

                  const SizedBox(width: 20),

                  const Text(
                    "Condizioni\nMediche",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. CARD CENTRALE CON GLI SWITCH ---
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: ListView(
                    // ListView permette di scorrere se ci sono molte opzioni
                    children: [
                      _buildSwitchTile("Disabilità motorie", _disabilitaMotorie, (val) {
                        setState(() => _disabilitaMotorie = val);
                      }, activeSwitchColor),

                      _buildDivider(),

                      _buildSwitchTile("Disabilità visive", _disabilitaVisive, (val) {
                        setState(() => _disabilitaVisive = val);
                      }, activeSwitchColor),

                      _buildDivider(),

                      _buildSwitchTile("Disabilità uditive", _disabilitaUditive, (val) {
                        setState(() => _disabilitaUditive = val);
                      }, activeSwitchColor),

                      _buildDivider(),

                      _buildSwitchTile("Disabilità intellettive", _disabilitaIntellettive, (val) {
                        setState(() => _disabilitaIntellettive = val);
                      }, activeSwitchColor),

                      _buildDivider(),

                      _buildSwitchTile("Disabilità psichiche", _disabilitaPsichiche, (val) {
                        setState(() => _disabilitaPsichiche = val);
                      }, activeSwitchColor),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // --- 3. BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20.0),
        height: 70,
        decoration: BoxDecoration(
          color: navBarColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: const Icon(Icons.home_outlined, color: Colors.white, size: 30), onPressed: () {}),
            IconButton(icon: const Icon(Icons.medical_information, color: Colors.white, size: 30), onPressed: () {}), // Pagina attiva
            IconButton(icon: const Icon(Icons.map_outlined, color: Colors.white, size: 30), onPressed: () {}),
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white, size: 30), onPressed: () {}),
            IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 30), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  // Widget per creare una riga con testo e switch
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Transform.scale(
            scale: 1.2, // Rende lo switch un po' più grande come nello screen
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor, // Colore pallino quando attivo
              activeTrackColor: Colors.white.withOpacity(0.3), // Colore scia quando attivo
              inactiveThumbColor: Colors.grey.shade300,
              inactiveTrackColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Spazio opzionale tra gli elementi (se vuoi le linee, usa Divider(), qui uso spazio vuoto)
  Widget _buildDivider() {
    return const SizedBox(height: 10);
  }
}