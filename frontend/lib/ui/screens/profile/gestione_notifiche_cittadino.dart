import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/notification_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

class GestioneNotificheCittadino extends StatefulWidget {
  const GestioneNotificheCittadino({super.key});

  @override
  State<GestioneNotificheCittadino> createState() => _GestioneNotificheState();
}

class _GestioneNotificheState extends State<GestioneNotificheCittadino> {

  @override
  void initState() {
    super.initState();
    // Carica i dati reali dal server all'avvio della schermata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadNotifiche();
    });
  }

  @override
  Widget build(BuildContext context) {
    //Logica responsive
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    final isRescuer = context.watch<AuthProvider>().isRescuer;
    Color cardColor = isRescuer ? ColorPalette.cardDarkOrange : ColorPalette.backgroundDarkBlue;
    Color bgColor = isRescuer ? ColorPalette.primaryOrange : ColorPalette.backgroundMidBlue;
    Color activeColor = isRescuer ? ColorPalette.backgroundMidBlue : ColorPalette.primaryOrange;

    final double titleSize = isWideScreen ? 40 : 30;
    final double iconSize = isWideScreen ? 50 : 40;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.notifications,
                        color: Colors.yellowAccent,
                        size: iconSize,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Gestione\nNotifiche",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista switch
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: isWideScreen ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ] : [],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Consumer<NotificationProvider>(
                        builder: (context, provider, child) {

                          if (provider.isLoading) {
                            return const Center(child: CircularProgressIndicator(color: Colors.white));
                          }

                          if (provider.errorMessage != null) {
                            return Center(
                                child: Text(
                                    "Errore: ${provider.errorMessage}",
                                    style: const TextStyle(color: Colors.redAccent)
                                )
                            );
                          }

                          final notif = provider.notifiche;

                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildSwitchItem(
                                "Notifiche Push",
                                notif.push,
                                    (val) => provider.updateNotifiche(
                                    notif.copyWith(push: val)
                                ),
                                activeColor,
                                isWideScreen,
                              ),
                              const SizedBox(height: 20),

                              _buildSwitchItem(
                                "Notifiche SMS",
                                notif.sms,
                                    (val) => provider.updateNotifiche(
                                    notif.copyWith(sms: val)
                                ),
                                activeColor,
                                isWideScreen,
                              ),
                              const SizedBox(height: 20),

                              _buildSwitchItem(
                                "Notifiche E-mail",
                                notif.mail,
                                    (val) => provider.updateNotifiche(
                                    notif.copyWith(mail: val)
                                ),
                                activeColor,
                                isWideScreen,
                              ),
                              const SizedBox(height: 20),

                              _buildSwitchItem(
                                "Silenzia tutto",
                                notif.silenzia,
                                    (val) => provider.updateNotifiche(
                                    notif.copyWith(silenzia: val)
                                ),
                                activeColor,
                                isWideScreen,
                              ),
                              const SizedBox(height: 20),

                              _buildSwitchItem(
                                "Aggiornamenti App",
                                notif.aggiornamenti,
                                    (val) => provider.updateNotifiche(
                                    notif.copyWith(aggiornamenti: val)
                                ),
                                activeColor,
                                isWideScreen,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(
      String title,
      bool value,
      Function(bool) onChanged,
      Color activeColor,
      bool isWideScreen,
      ) {
    final double labelSize = isWideScreen ? 22 : 18;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: labelSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Transform.scale(
          scale: isWideScreen ? 1.3 : 1.1,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: activeColor,
            activeTrackColor: Colors.white.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey.shade300,
            inactiveTrackColor: Colors.white24,
          ),
        ),
      ],
    );
  }
}