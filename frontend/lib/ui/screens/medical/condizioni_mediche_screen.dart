import 'package:flutter/material.dart';

class CondizioniMedicheScreen extends StatefulWidget {
  const CondizioniMedicheScreen({super.key});

  @override
  State<CondizioniMedicheScreen> createState() => _CondizioniMedicheScreenState();
}

class _CondizioniMedicheScreenState extends State<CondizioniMedicheScreen> {
  // Stato locale (In futuro andrà nel MedicalProvider)
  bool _disabilitaMotorie = true;
  bool _disabilitaVisive = false;
  bool _disabilitaUditive = false;
  bool _disabilitaIntellettive = false;
  bool _disabilitaPsichiche = false;

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF12345A);
    const Color cardColor = Color(0xFF0E2A48);
    const Color activeSwitchColor = Color(0xFFEF923D); // Arancione

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
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
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_3, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Condizioni\nMediche",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- CARD SWITCH ---
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
                    children: [
                      _buildSwitchTile("Disabilità motorie", _disabilitaMotorie, (val) {
                        setState(() => _disabilitaMotorie = val);
                      }, activeSwitchColor),
                      const SizedBox(height: 10),

                      _buildSwitchTile("Disabilità visive", _disabilitaVisive, (val) {
                        setState(() => _disabilitaVisive = val);
                      }, activeSwitchColor),
                      const SizedBox(height: 10),

                      _buildSwitchTile("Disabilità uditive", _disabilitaUditive, (val) {
                        setState(() => _disabilitaUditive = val);
                      }, activeSwitchColor),
                      const SizedBox(height: 10),

                      _buildSwitchTile("Disabilità intellettive", _disabilitaIntellettive, (val) {
                        setState(() => _disabilitaIntellettive = val);
                      }, activeSwitchColor),
                      const SizedBox(height: 10),

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
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor,
              activeTrackColor: Colors.white.withOpacity(0.3),
              inactiveThumbColor: Colors.grey.shade300,
              inactiveTrackColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}