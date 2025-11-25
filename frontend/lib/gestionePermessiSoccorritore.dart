import 'package:flutter/material.dart';
// import 'package:frontend/navigationBarSoccorritore.dart'; // Scommenta se il file esiste

// Funzione helper per i colori
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode"; // Aggiunge Alpha 255 (opacità massima)
  }
  return Color(int.parse(hexCode, radix: 16));
}

// --- CLASSE RINOMINATA CORRETTAMENTE ---
class GestionePermessiSoccorritore extends StatelessWidget {

  final String title;
  final Color? backgroundColor;

  // Costruttore con valori di default
  const GestionePermessiSoccorritore({
    super.key,
    this.title = 'Gestione\nPermessi',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Colore di sfondo default: Arancione Soccorritore (ef923d)
    final Color effectiveBgColor = backgroundColor ?? hexToColor("ef923d");
    // Colore Card: Arancione scuro (D65D01)
    final Color cardColor = hexToColor("D65D01");

    return Scaffold(
      backgroundColor: effectiveBgColor,
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
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
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
                            const Icon(
                              Icons.verified_user,
                              color: Colors.blueAccent,
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

              // 2. SEZIONE PERMESSI
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: const Column(
                    children: [
                      PermissionRow(title: 'Accesso alla posizione', initialValue: false),
                      PermissionRow(title: 'Accesso ai contatti', initialValue: false),
                      PermissionRow(title: 'Accesso alle notifiche di sistema', initialValue: false),
                      PermissionRow(title: 'Accesso alla memoria', initialValue: false),
                      PermissionRow(title: 'Accesso al Bluetooth', initialValue: false),
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

// --- WIDGET RIGA PERMESSO (RIUTILIZZABILE) ---
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
              // Colori dello switch (Contrasto Blu su Arancione)
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