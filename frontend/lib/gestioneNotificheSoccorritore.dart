import 'package:flutter/material.dart';
// import 'package:frontend/navigationBarSoccorritore.dart'; // Scommenta se necessario

// Funzione per convertire la stringa Hex (senza alpha) in un oggetto Color.
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode"; // Aggiunge Alpha 255 (opacità massima)
  }
  return Color(int.parse(hexCode, radix: 16));
}

// --- CLASSE RINOMINATA CORRETTAMENTE ---
class GestioneNotificheSoccorritore extends StatelessWidget {
  final String title;
  final Color? backgroundColor;

  // Costruttore con valori di default
  const GestioneNotificheSoccorritore({
    super.key,
    this.title = 'Gestione\nNotifiche',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Colore di sfondo default: Arancione Soccorritore (ef923d)
    final Color effectiveBgColor = backgroundColor ?? hexToColor("ef923d");
    // Colore del blocco centrale: Arancione Scuro (D65D01)
    final Color cardColor = hexToColor("D65D01");

    return Scaffold(
      // Colore di sfondo preso da MyApp
      backgroundColor: effectiveBgColor,

      // La BottomNavigationBar e la parte superiore
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Freccia Indietro + Titolo)
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 16.0,
                  bottom: 20.0,
                ),
                child: Row(
                  children: [
                    // implementazione del pulsante indietro
                    InkWell(
                      onTap: () {
                        Navigator.pop(
                          context,
                        ); // tolgo questa pagina dallo stack di navigazione
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),

                    // Icona e Titolo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Icona
                            Icon(
                              Icons.notifications,
                              // Contrasto Blu scuro su arancione, o giallo/oro come preferisci.
                              // Nel codice originale era giallo (e3c63d), ma su arancione potrebbe vedersi poco.
                              // Qui lascio quello che avevi, o puoi mettere Colors.white o BlueAccent.
                              color: hexToColor('e3c63d'),
                              size: 40,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ) ?? const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. SEZIONE IMPOSTAZIONI (La "Card" Arancione Scuro)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor, // Colore del blocco
                    borderRadius: BorderRadius.circular(25.0),
                  ),

                  child: const Column(
                    children: [
                      PermissionRow(
                        title: 'Notifiche push',
                        initialValue: false,
                      ),
                      PermissionRow(
                        title: 'Notifiche SMS',
                        initialValue: false,
                      ),
                      PermissionRow(
                        title: 'Notifiche e-mail',
                        initialValue: false,
                      ),
                      PermissionRow(
                        title: 'Aggiornamenti',
                        initialValue: false,
                      ),
                      PermissionRow(
                        title: 'Silenzia notifiche',
                        initialValue: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CustomBottomNavBar(), // Scommenta se necessario
    );
  }
}

// --- WIDGET RIGA (RIUTILIZZABILE) ---
class PermissionRow extends StatefulWidget {
  final String title;
  final bool initialValue;

  const PermissionRow({
    super.key,
    required this.title,
    required this.initialValue,
  });

  @override
  State<PermissionRow> createState() => _PermissionRowState();
}

class _PermissionRowState extends State<PermissionRow> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Testo del permesso
          Flexible(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ) ?? const TextStyle(color: Colors.white, fontSize: 18),
              softWrap: true,
            ),
          ),

          // Interruttore (Switch)
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: _isEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _isEnabled = newValue;
                });

                final String statusText = newValue ? 'attivato' : 'disattivato';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${widget.title}" $statusText.'),
                    duration: const Duration(milliseconds: 750),
                  ),
                );
              },

              // Colori dello switch (Versione Soccorritore: Blu scuro su Arancione)
              activeTrackColor: hexToColor("12345a"),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}