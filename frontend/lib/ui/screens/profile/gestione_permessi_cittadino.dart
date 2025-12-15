import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/permission_provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata Gestione Permessi Cittadino
// Consente all'utente di attivare o disattivare i permessi di sistema.
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
    // Carica le preferenze di permessi dal server all'avvio della schermata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PermissionProvider>(context, listen: false).loadPermessi();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logica responsive e color palette basata sul ruolo dell'utente
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    final isRescuer = context.watch<AuthProvider>().isRescuer;
    Color cardColor = isRescuer
        ? ColorPalette.cardDarkOrange
        : ColorPalette.backgroundDarkBlue;
    Color bgColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundMidBlue;
    Color activeColor = isRescuer
        ? ColorPalette.backgroundMidBlue
        : ColorPalette.primaryOrange;

    // Dimensioni adattate allo stile di "Modifica Profilo" e "Gestione Notifiche"
    final double titleSize = isWideScreen ? 50 : 28;
    final double iconSize = isWideScreen ? 60 : 40;
    final double switchLabelSize = isWideScreen ? 26 : 16;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: isWideScreen ? 36 : 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.verified_user,
                        color: Colors.blueAccent,
                        size: iconSize,
                      ),
                      const SizedBox(width: 15),
                      // Titolo ora su una riga singola
                      Text(
                        "Gestione Permessi",
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

                // --- LISTA SWITCH ---
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isWideScreen ? 40.0 : 20.0),
                      // Consumer: Ascolta i cambiamenti nel PermissionProvider
                      child: Consumer<PermissionProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }

                          if (provider.errorMessage != null) {
                            return Center(
                              child: Text(
                                "Errore: ${provider.errorMessage}",
                                style: const TextStyle(color: Colors.redAccent),
                              ),
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
                                    permessi.copyWith(posizione: val),
                                  );
                                },
                                activeColor,
                                isWideScreen,
                                switchLabelSize,
                              ),
                              const SizedBox(
                                height: 30,
                              ), // Spaziatura aumentata

                              _buildSwitchItem(
                                "Accesso ai contatti",
                                permessi.contatti,
                                (val) {
                                  provider.updatePermessi(
                                    permessi.copyWith(contatti: val),
                                  );
                                },
                                activeColor,
                                isWideScreen,
                                switchLabelSize,
                              ),
                              const SizedBox(height: 30),

                              _buildSwitchItem(
                                "Notifiche di sistema",
                                permessi.notificheSistema,
                                (val) {
                                  provider.updatePermessi(
                                    permessi.copyWith(notificheSistema: val),
                                  );
                                },
                                activeColor,
                                isWideScreen,
                                switchLabelSize,
                              ),
                              const SizedBox(height: 30),

                              _buildSwitchItem(
                                "Accesso al Bluetooth",
                                permessi.bluetooth,
                                (val) {
                                  provider.updatePermessi(
                                    permessi.copyWith(bluetooth: val),
                                  );
                                },
                                activeColor,
                                isWideScreen,
                                switchLabelSize,
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

  // Widget Helper: Elemento Switch per la lista
  Widget _buildSwitchItem(
    String title,
    bool value,
    Function(bool) onChanged,
    Color activeColor,
    bool isWideScreen,
    double labelSize,
  ) {
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
