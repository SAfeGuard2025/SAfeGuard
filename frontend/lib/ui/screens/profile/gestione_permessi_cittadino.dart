import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/permission_provider.dart';
import 'package:frontend/providers/auth_provider.dart';

class GestionePermessiCittadino extends StatefulWidget {
  const GestionePermessiCittadino({super.key});

  @override
  State<GestionePermessiCittadino> createState() =>
      _GestionePermessiCittadinoState();
}

class _GestionePermessiCittadinoState extends State<GestionePermessiCittadino> {

  @override
  void initState() {
    super.initState();
    // Carica i permessi reali dal server all'avvio [cite: 554]
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PermissionProvider>(context, listen: false).loadPermessi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    Color cardColor = isRescuer ? Color(0xFFD65D01) : Color(0xFF0E2A48);
    Color bgColor = isRescuer ? Color(0xFFEF923D) : Color(0xFF12345A);
    Color activeColor = isRescuer ? Color(0xFF12345A) : Color(0xFFEF923D);

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

            // LISTA DINAMICA DAL PROVIDER
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  // Consumer ascolta i cambiamenti nel Provider [cite: 553]
                  child: Consumer<PermissionProvider>(
                    builder: (context, provider, child) {

                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return Center(
                            child: Text(
                                "Errore: ${provider.errorMessage}",
                                style: const TextStyle(color: Colors.red)
                            )
                        );
                      }

                      // Otteniamo l'oggetto Permesso attuale
                      final permessi = provider.permessi;

                      return ListView(
                        children: [
                          _buildSwitchItem(
                              "Accesso alla posizione",
                              permessi.posizione,
                                  (val) {
                                // Aggiorna il DB tramite provider
                                provider.updatePermessi(
                                    permessi.copyWith(posizione: val)
                                );
                              },
                              activeColor
                          ),
                          const SizedBox(height: 15),

                          _buildSwitchItem(
                              "Accesso ai contatti",
                              permessi.contatti,
                                  (val) {
                                provider.updatePermessi(
                                    permessi.copyWith(contatti: val)
                                );
                              },
                              activeColor
                          ),
                          const SizedBox(height: 15),

                          _buildSwitchItem(
                              "Notifiche di sistema",
                              permessi.notificheSistema,
                                  (val) {
                                provider.updatePermessi(
                                    permessi.copyWith(notificheSistema: val)
                                );
                              },
                              activeColor
                          ),
                          const SizedBox(height: 15),

                          _buildSwitchItem(
                              "Accesso al Bluetooth",
                              permessi.bluetooth,
                                  (val) {
                                provider.updatePermessi(
                                    permessi.copyWith(bluetooth: val)
                                );
                              },
                              activeColor
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50), // Spazio inferiore ridotto
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
          scale: 1.1, // Switch leggermente più grande
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