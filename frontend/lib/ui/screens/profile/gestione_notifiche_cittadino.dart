import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/notification_provider.dart';

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
    const Color cardColor = Color(0xFF12345A);
    const Color bgColor = Color(0xFF0E2A48);
    const Color activeColor = Color(0xFFEF923D);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
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
                  const Icon(
                    Icons.notifications,
                    color: Colors.yellowAccent,
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

            // LISTA SWITCH
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Consumer<NotificationProvider>(
                    builder: (context, provider, child) {

                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
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
                        children: [
                          _buildSwitchItem(
                            "Notifiche Push",
                            notif.push,
                                (val) => provider.updateNotifiche(
                                notif.copyWith(push: val)
                            ),
                            activeColor,
                          ),
                          const SizedBox(height: 15),

                          _buildSwitchItem(
                            "Notifiche SMS",
                            notif.sms,
                                (val) => provider.updateNotifiche(
                                notif.copyWith(sms: val)
                            ),
                            activeColor,
                          ),
                          const SizedBox(height: 15),

                          _buildSwitchItem(
                            "Notifiche E-mail",
                            notif.mail,
                                (val) => provider.updateNotifiche(
                                notif.copyWith(mail: val)
                            ),
                            activeColor,
                          ),
                          const SizedBox(height: 15),

                          _buildSwitchItem(
                            "Silenzia tutto",
                            notif.silenzia,
                                (val) => provider.updateNotifiche(
                                notif.copyWith(silenzia: val)
                            ),
                            activeColor,
                          ),
                          const SizedBox(height: 15),

                          _buildSwitchItem(
                            "Aggiornamenti App",
                            notif.aggiornamenti,
                                (val) => provider.updateNotifiche(
                                notif.copyWith(aggiornamenti: val)
                            ),
                            activeColor,
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
    );
  }

  Widget _buildSwitchItem(
      String title,
      bool value,
      Function(bool) onChanged,
      Color activeColor
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Transform.scale(
          scale: 1.1,
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