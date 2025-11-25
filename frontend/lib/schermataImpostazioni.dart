import 'package:flutter/material.dart';
import 'package:frontend/gestioneNotificheCittadino.dart';
import 'package:frontend/gestionePermessiCittadino.dart';
import 'package:frontend/navigationBarCittadino.dart';
import 'package:frontend/gestioneCartellaClinicaCittadino.dart';
import 'package:frontend/gestioneNotificheSoccorritore.dart';
import 'package:frontend/gestionePermessiSoccorritore.dart';
import 'package:frontend/navigationBarSoccorritore.dart';
import 'package:frontend/gestioneModificaProfiloCittadino.dart';
import 'package:frontend/gestioneModificaProfiloSoccorritore.dart';




// --- WIDGET PRINCIPALE ---
class ProfileSettingsScreen extends StatefulWidget {
  // Passiamo questa variabile per sapere chi è l'utente.
  final bool isSoccorritore;

  const ProfileSettingsScreen({super.key, required this.isSoccorritore});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {

  // Metodo helper per la navigazione
  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definizione colori dal design
    final Color kBackgroundColor = const Color(0xFF012345A); // Blu sfondo
    final Color kCardColor = const Color(0xFF0E2A48); // Blu per le card
    final Color kAccentOrange = const Color(0xFFEF923D); // Arancione
    final Color kTextWhite = Colors.white;
    final Color kTextGrey = Colors.white70;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      // Questo è il BODY della schermata.
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER PROFILO ---
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: kAccentOrange,
                          child: CircleAvatar(
                            radius: 42,
                            // Inserire l'avatar 3D
                            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=11'),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: kBackgroundColor, width: 2),
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ciao,",
                          style: TextStyle(
                            color: kTextWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Mario Rossi",
                          style: TextStyle(
                            color: kAccentOrange,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 30),

                // Carosello delle Impostazioni
                Text(
                  "Impostazioni",
                  style: TextStyle(color: kTextWhite, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      //CARD 1: NOTIFICHE
                      _buildSettingCard(
                        title: "Notifiche",
                        subtitle: "Gestione Notifiche",
                        icon: Icons.notifications_active,
                        iconColor: Colors.yellow,
                        bgColor: kCardColor,
                        onTap: () {
                          if (widget.isSoccorritore) {
                            _navigateTo(const GestioneNotificheSoccorritore());
                          } else {
                            _navigateTo(const GestioneNotificheCittadino());
                          }
                        },
                      ),
                      const SizedBox(width: 15),

                       //CARD 2: CARTELLA CLINICA
                      _buildSettingCard(
                        title: "Cartella clinica",
                        subtitle: "Impostazioni",
                        icon: Icons.medical_services_outlined,
                        iconColor: Colors.white, // O un'immagine custom
                        bgColor: kCardColor,
                        onTap: () {
                            _navigateTo(const GestioneCartellaClinicaCittadino());
                        },
                      ),
                      const SizedBox(width: 15),

                      // CARD 3: PERMESSI
                      _buildSettingCard(
                        title: "Permessi",
                        subtitle: "Gestione Permessi",
                        icon: Icons.security,
                        iconColor: Colors.blueAccent,
                        bgColor: kCardColor,
                        onTap: () {
                          if (widget.isSoccorritore) {
                            // Assicurati che anche il file del Soccorritore abbia la classe rinominata correttamente!
                            _navigateTo(const GestionePermessiSoccorritore());
                          } else {
                            // Ora questo funziona perché la classe esiste nel file che ti ho dato sopra
                            _navigateTo(const GestionePermessiCittadino());
                          }
                        },
                      ),
                      const SizedBox(width: 15),

                       //CARD 4: MODIFICA PROFILO
                      _buildSettingCard(
                        title: "Modifica Profilo",
                        subtitle: "Modifica Profilo",
                        icon: Icons.settings,
                        iconColor: Colors.grey,
                        bgColor: kCardColor,
                        onTap: () {
                          if (widget.isSoccorritore) {
                            _navigateTo(const GestioneModificaProfiloSoccorritore());
                          } else {
                            _navigateTo(const GestioneModificaProfiloCittadino());
                          }
                        },
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 30),


                // Richieste di aiuto
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kCardColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Richieste di aiuto",
                            style: TextStyle(color: kTextWhite, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Guarda Tutto",
                                style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                              )
                          )
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Esempi di richieste
                      _buildRequestItem(
                        title: "Richiesta ambulanza",
                        time: "02:00 AM",
                        status: "Incompleta",
                        isComplete: false,
                        icon: Icons.local_fire_department_outlined, // Usa un asset image se preferisci
                        iconBgColor: Colors.orangeAccent,
                      ),
                      _buildRequestItem(
                        title: "Terremoto",
                        time: "12:30 AM",
                        status: "Completata",
                        isComplete: true,
                        icon: Icons.broken_image,
                        iconBgColor: Colors.brown,
                      ),
                      _buildRequestItem(
                        title: "Incendio",
                        time: "3:50 PM",
                        status: "Completata",
                        isComplete: true,
                        icon: Icons.local_fire_department,
                        iconBgColor: Colors.deepOrange,
                      ),
                    ],
                  ),
                ),
                // Spazio extra in fondo per non coprire con la navbar
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER PER LE CARD ---
  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140,
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER PER LA LISTA RICHIESTE ---
  Widget _buildRequestItem({
    required String title,
    required String time,
    required String status,
    required bool isComplete,
    required IconData icon,
    required Color iconBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  time,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: isComplete ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // Metti 'true' se vuoi testare la vista soccorritore
    home: ProfileSettingsScreen(isSoccorritore: false),
  ));
}
