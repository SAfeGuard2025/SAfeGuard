import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/sos_button.dart'; // Importiamo il widget separato
// Importa qui la schermata dei contatti quando l'avrai creata/spostata
// import 'package:frontend/ui/screens/medical/contatti_emergenza_screen.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  // Definiamo i colori localmente o usiamo quelli del Theme
  final Color darkBlue = const Color(0xFF041528);
  final Color primaryRed = const Color(0xFFE53935);
  final Color amberOrange = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Permette lo scroll se lo schermo è piccolo
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // 1. NOTIFICA DI EMERGENZA
            _buildEmergencyNotification(),

            const SizedBox(height: 25),

            // 2. MAPPA (Placeholder)
            _buildMapPlaceholder(),

            const SizedBox(height: 20),

            // 3. BOTTONE "CONTATTI DI EMERGENZA"
            _buildEmergencyContactsButton(context),

            const SizedBox(height: 20),

            // 4. BOTTONE SOS GRANDE
            // Calcoliamo la dimensione in base alla larghezza dello schermo
            _buildSosSection(context),

            const SizedBox(height: 30), // Spazio extra in fondo
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildEmergencyNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.house_siding_rounded, color: Colors.white, size: 28),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Incendio",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "Incendio in Via Roma, 14",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 225,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF0E2A48), // Un blu leggermente più chiaro dello sfondo
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, color: Colors.white70, size: 60),
          SizedBox(height: 10),
          Text(
            "Mappa",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "(Implementazione futura)",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigazione ai contatti (quando avrai spostato il file)
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const ContattiEmergenzaScreen()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Apertura contatti emergenza...")),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: amberOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_pin_circle, color: darkBlue, size: 28),
          const SizedBox(width: 10),
          Text(
            "Contatti di Emergenza",
            style: TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosSection(BuildContext context) {
    final double buttonSize = MediaQuery.of(context).size.width * 0.60;
    return SosButton(size: buttonSize);
  }
}