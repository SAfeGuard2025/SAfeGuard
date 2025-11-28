import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/auth/registration_screen.dart';
import 'package:frontend/ui/screens/home/confirm_emergency_screen.dart';
import 'package:frontend/ui/screens/medical/contatti_emergenza_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/widgets/emergency_item.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});


  // Colori della pagina
  final Color darkBlue = const Color(0xFF041528);
  final Color primaryRed = const Color(0xFFE53935);
  final Color amberOrange = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final isRescuer = context
        .watch<AuthProvider>()
        .isRescuer;


    // Permette lo scroll se lo schermo è piccolo
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            /*
            // se ci sono avvisi recenti si deve attivare
            _buildEmergencyNotification(),
             */
            const SizedBox(height: 25),
            _buildMapPlaceholder(isRescuer),
            const SizedBox(height: 20),
            if(!isRescuer) _buildEmergencyContactsButton(context),
            const SizedBox(height: 20),
            _buildSosSection(context),

            const SizedBox(height: 20),
            if(isRescuer) _buildSpecificEmergency(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /*// costruzione della notifica
  // mettere controllo su isLogged

  Widget _buildEmergencyNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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

 */

  Widget _buildMapPlaceholder(bool isRescuer) {
    return Container(
      height: isRescuer ? 300 : 225,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(
          0xFF0E2A48, // Un blu leggermente più chiaro dello sfondo
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
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
    // controllo se l'utente è loggato, se lo è mostro i contatti di emergenza se no mostra il tasto per andare alla registrazione
    final isLogged = context.watch<AuthProvider>().isLogged;
    if(!isLogged){

      //return Text("");

      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrationScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          elevation: 5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 10),
            Text(
              "Registrati",
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

      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContattiEmergenzaScreen(),
            ),
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
    // controllo se l'utente è loggato, se lo è mostro il pulsante di SOS se no niente
    final isLogged = context.watch<AuthProvider>().isLogged;
    if(!isLogged){
      return Text("");
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ConfirmEmergencyScreen()),
        );
      },
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: const DecorationImage(
            image: AssetImage('assets/sosbutton.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecificEmergency(BuildContext context) {
    return EmergencyDropdownMenu(
        items: [
          EmergencyItem(label: "Terremoto", icon: Icons.waves),
          EmergencyItem(label: "Incendio", icon: Icons.local_fire_department),
          EmergencyItem(label: "Tsunami", icon: Icons.water),
          EmergencyItem(label: "Alluvione", icon: Icons.flood),
          EmergencyItem(label: "Malessere", icon: Icons.medical_services),
          EmergencyItem(label: "Bomba", icon: Icons.warning),
        ],
        onSelected: (item) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Hai selezionato: ${item.label}"),
              backgroundColor: Colors.black,
            ),
          );
        }
    );
  }
}

