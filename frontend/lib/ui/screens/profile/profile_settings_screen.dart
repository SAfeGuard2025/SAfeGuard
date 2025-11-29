import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_models/help_request_item.dart';
import 'package:frontend/ui/screens/profile/gestione_notifiche_cittadino.dart';
import 'package:frontend/ui/screens/profile/gestione_permessi_cittadino.dart';
import 'package:frontend/ui/screens/profile/gestione_modifica_profilo_cittadino.dart';
import 'package:frontend/ui/screens/medical/gestione_cartella_clinica_cittadino.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/screens/auth/login_screen.dart';
import 'package:frontend/ui/style/color_palette.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Dati simulati delle richieste
  final List<HelpRequestItem> requests = [];

  // Funzione di logout
  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disconnessione fallita. Riprova: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    // Ottiene lo stato isRescuer dal Provider
    final provider = context.watch<AuthProvider>();
    final isRescuer = provider.isRescuer;

    // Recupero dati utente
    final user = provider.currentUser;
    final String nomeCompleto = (user?.nome != null && user?.cognome != null)
        ? "${user!.nome} ${user.cognome}"
        : "Utente";

    final kCardColor = isRescuer ? ColorPalette.cardDarkOrange : ColorPalette.backgroundMidBlue;
    final kBackgroundColor = isRescuer ? ColorPalette.primaryOrange : ColorPalette.backgroundDarkBlue;
    final Color kAccentOrange = !isRescuer ? ColorPalette.primaryOrange : ColorPalette.backgroundDarkBlue;

    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    // Crea la lista delle card dinamicamente
    List<Widget> settingCards = [
      _buildSettingCard(
        "Notifiche",
        "Gestione Notifiche",
        Icons.notifications_active,
        Colors.yellow,
        kCardColor,
            () => _navigateTo(context, const GestioneNotificheCittadino()),
        isWideScreen,
      ),
      if (!isRescuer)
        _buildSettingCard(
          "Cartella clinica",
          "Cartella Clinica",
          Icons.medical_services_outlined,
          Colors.white,
          kCardColor,
              () => _navigateTo(context, const GestioneCartellaClinicaCittadino()),
          isWideScreen,
        ),
      _buildSettingCard(
        "Permessi",
        "Gestione Permessi",
        Icons.security,
        Colors.blueAccent,
        kCardColor,
            () => _navigateTo(context, const GestionePermessiCittadino()),
        isWideScreen,
      ),
      _buildSettingCard(
        "Modifica Profilo",
        "Modifica Profilo",
        Icons.settings,
        Colors.grey,
        kCardColor,
            () => _navigateTo(context, const GestioneModificaProfiloCittadino()),
        isWideScreen,
      ),
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: Text(
          isRescuer ? "Dashboard Soccorritore" : "Profilo Cittadino",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Esci dal tuo account',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [

                // Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: isWideScreen ? 60 : 45,
                        backgroundColor: kAccentOrange,
                        child: CircleAvatar(
                          radius: isWideScreen ? 56 : 42,
                          backgroundImage: const AssetImage("assets/cavalluccio.png"),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ciao,",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isWideScreen ? 32 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              nomeCompleto,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: kAccentOrange,
                                fontSize: isWideScreen ? 32 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenuto scorrevole (Impostazioni + Lista)
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          Text(
                            "Impostazioni",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWideScreen ? 28 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: settingCards.map((card) {
                                return Padding(
                                  padding: EdgeInsets.only(right: isWideScreen ? 25.0 : 15.0),
                                  child: card,
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Lista richieste
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
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
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isWideScreen ? 22 : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "Guarda Tutto",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Futura implementazione",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
      String title,
      String subtitle,
      IconData icon,
      Color iconColor,
      Color bgColor,
      VoidCallback onTap,
      bool isWideScreen,
      ) {
    final double cardWidth = isWideScreen ? 200 : 140;
    final double cardHeight = isWideScreen ? 180 : 160;
    final double iconSize = isWideScreen ? 50 : 40;
    final double titleSize = isWideScreen ? 18 : 16;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 4),
              )
            ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: iconColor),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: titleSize,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}