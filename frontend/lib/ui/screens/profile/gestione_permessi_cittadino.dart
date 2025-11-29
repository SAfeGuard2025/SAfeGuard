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
    // Carica i permessi reali dal server all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PermissionProvider>(context, listen: false).loadPermessi();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logica responsive
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    final isRescuer = context.watch<AuthProvider>().isRescuer;
    Color cardColor = isRescuer ? const Color(0xFFD65D01) : const Color(0xFF0E2A48);
    Color bgColor = isRescuer ? const Color(0xFFEF923D) : const Color(0xFF12345A);
    Color activeColor = isRescuer ? const Color(0xFF12345A) : const Color(0xFFEF923D);

    final double titleSize = isWideScreen ? 40 : 30;
    final double headerIconSize = isWideScreen ? 50 : 40;

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
                        Icons.verified_user,
                        color: Colors.blueAccent,
                        size: headerIconSize,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Gestione\nPermessi",
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
                      child: Consumer<PermissionProvider>(
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

                          final permessi = provider.permessi;

                          return ListView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildSwitchItem(
                                  "Accesso alla posizione",
                                  permessi.posizione,
                                      (val) {
                                    provider.updatePermessi(
                                        permessi.copyWith(posizione: val)
                                    );
                                  },
                                  activeColor,
                                  isWideScreen
                              ),
                              const SizedBox(height: 20),

                              _buildSwitchItem(
                                  "Accesso ai contatti",
                                  permessi.contatti,
                                      (val) {
                                    provider.updatePermessi(
                                        permessi.copyWith(contatti: val)
                                    );
                                  },
                                  activeColor,
                                  isWideScreen
                              ),
                              const SizedBox(height: 20),

                              _buildSwitchItem(
                                  "Notifiche di sistema",
                                  permessi.notificheSistema,
                                      (val) {
                                    provider.updatePermessi(
                                        permessi.copyWith(notificheSistema: val)
                                    );
                                  },
                                  activeColor,
                                  isWideScreen
                              ),
                              const SizedBox(height: 20),

                              _buildSwitchItem(
                                  "Accesso al Bluetooth",
                                  permessi.bluetooth,
                                      (val) {
                                    provider.updatePermessi(
                                        permessi.copyWith(bluetooth: val)
                                    );
                                  },
                                  activeColor,
                                  isWideScreen
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