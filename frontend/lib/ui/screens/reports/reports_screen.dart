import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/providers/emergency_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/realtime_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/widgets/emergency_item.dart';

// Schermata per la creazione e l'invio di nuove segnalazioni/emergenze.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // Stato del checkbox "Ho bisogno di aiuto" (usato solo dai cittadini).
  bool _needsHelp = false;
  // Controller per il campo di testo della descrizione.
  final TextEditingController _descriptionController = TextEditingController();
  EmergencyItem? _selectedEmergency;

  // Variabile per memorizzare la posizione scelta dall'utente sulla mappa
  LatLng? _selectedLocation;

  //UNZIONE HELPER PER CALCOLO AUTOMATICO SEVERITÀ
  int _calculateAutomaticSeverity(String type) {
    final t = type.toLowerCase();

    // LIVELLO 4: Alto (Arancione) - Catastrofi e Incendi
    if (t.contains('bomba') ||
        t.contains('terremoto') ||
        t.contains('tsunami') ||
        t.contains('incendio')) {
      return 4;
    }
    // LIVELLO 3: Medio (Meteo)
    else if (t.contains('alluvione')) {
      return 3;
    }
    // LIVELLO 2: Basso (Medico)
    else if (t.contains('malessere')) {
      return 2;
    }

    // LIVELLO 1: Default (SOS Generico o altro)
    return 1;
  }
  // -------------------------------------------------------

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Metodo per aprire il popup della mappa
  void _openMapDialog(BuildContext context) {
    // Variabile locale per tenere traccia del punto selezionato.
    LatLng? tempPoint;

    showDialog(
      context: context,
      barrierDismissible: false, // Impedisce chiusura cliccando fuori
      builder: (BuildContext context) {
        // StatefulBuilder serve per aggiornare la UI dentro il Dialog
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              // Configurazione estetica del Dialog
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 550,
                  child: Stack(
                    children: [
                      // Mappa interattiva
                      RealtimeMap(
                        isSelectionMode: true,
                        onLocationPicked: (point) {
                          // Callback chiamato quando l'utente seleziona un punto sulla mappa.
                          // Aggiorna la variabile locale e ricostruisce solo il Dialog.
                          setStateDialog(() {
                            tempPoint = point;
                          });
                        },
                      ),

                      // Tasto X per chiudere
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ),

                      // Tasto Conferma visibile solo se il punto è stato selezionato
                      if (tempPoint != null)
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              // Stile bottone
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "CONFERMA POSIZIONE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () {
                                // Salvataggio della posizione nello stato principale
                                setState(() {
                                  _selectedLocation = tempPoint;
                                });
                                // Chiusura del dialog
                                Navigator.of(context).pop();

                                // Feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Posizione acquisita!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Invio Segnalazione
  Future<void> _sendEmergency(ReportProvider reportProvider) async {
    final String description = _descriptionController.text;

    // Validazione dei campi
    if (_selectedEmergency == null) {
      _showSnackBar(
        content: 'Inserisci un\'emergenza da segnalare',
        color: ColorPalette.emergencyButtonRed,
      );
      return;
    }

    if (_selectedLocation == null) {
      _showSnackBar(
        content: 'Seleziona un punto sulla mappa',
        color: ColorPalette.emergencyButtonRed,
      );
      return;
    }

    if (description.isEmpty) {
      _showSnackBar(
        content: 'Inserisci una descrizione',
        color: ColorPalette.emergencyButtonRed,
      );
      return;
    }

    //INVIA REPORT SPECIFICO
    int severity = _calculateAutomaticSeverity(_selectedEmergency!.label);

    bool reportSuccess = await reportProvider.sendReport(
      _selectedEmergency!.label,
      description,
      _selectedLocation!.latitude,
      _selectedLocation!.longitude,
      severity: severity,
    );

    if (!mounted) return;

    //SE "HO BISOGNO DI AIUTO", INVIA ANCHE SOS
    // Questo crea il puntino rosso che si sposta con l'utente.
    if (_needsHelp && reportSuccess) {
      final user = context.read<AuthProvider>().currentUser;

      if (user != null) {
        // Usiamo EmergencyProvider per inviare un SOS tracciato
        await context.read<EmergencyProvider>().sendInstantSos(
          userId: user.id.toString(),
          email: user.email,
          phone: user.telefono,
          type: "SOS Generico",
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("REPORT + SOS TRACCIATO INVIATI!"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    if (reportSuccess && mounted) {
      _showSnackBar(
        content: 'Segnalazione inviata con successo',
        color: Colors.green,
      );
      setState(() {
        _selectedEmergency = null;
        _descriptionController.clear();
        _selectedLocation = null;
        _needsHelp = false;
      });
    } else if (mounted) {
      _showSnackBar(
        content: 'Errore invio segnalazione. Riprova.',
        color: ColorPalette.emergencyButtonRed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700; // Logica per responsive design

    // Watch sui provider per accedere a ruoli e stati di caricamento.
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final reportProvider = context
        .watch<ReportProvider>(); // Per lo stato isLoading

    // Logica per l'adattamento dei colori e delle dimensioni in base al ruolo/schermo.
    Color bgColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundMidBlue;
    Color cardColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundDarkBlue;
    Color accentColor = isRescuer
        ? ColorPalette.backgroundMidBlue
        : ColorPalette.primaryOrange;

    final double titleSize = isWideScreen ? 50 : 28;
    final double labelFontSize = isWideScreen ? 24 : 14;
    final double inputFontSize = isWideScreen ? 26 : 16;
    final double buttonFontSize = isWideScreen ? 28 : 18;

    return Scaffold(
      backgroundColor: cardColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    "Crea segnalazione",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),

                // Bottone per aprire il dialog di selezione posizione
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _openMapDialog(context),
                    // Icona e testo cambiano a seconda che la posizione sia stata selezionata o meno.
                    icon: Icon(
                      _selectedLocation != null
                          ? Icons.check_circle
                          : Icons.map,
                      color: _selectedLocation != null
                          ? Colors.green
                          : Colors.blueAccent,
                    ),
                    label: Text(
                      _selectedLocation != null
                          ? "Posizione Selezionata"
                          : "Seleziona posizione sulla mappa",
                      style: TextStyle(
                        color: _selectedLocation != null
                            ? Colors.green
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Stile Bottone
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                // -----------------------------
                const SizedBox(height: 20.0),

                // Widget per la selezione del tipo di emergenza
                SizedBox(
                  height: 60,
                  child: _buildSpecificEmergency(context, isWideScreen),
                ),

                isRescuer ? SizedBox(height: 40.0) : SizedBox(height: 20.0),

                // Intestazione per la descrizione
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Aggiungi dettagli alla tua segnalazione",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),

                // Campo di testo per la descrizione
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  style: TextStyle(fontSize: inputFontSize),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Descrizione...',
                    hintStyle: TextStyle(
                      fontSize: inputFontSize,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                  ),
                ),

                const SizedBox(height: 20.0),

                // CheckBox "Ho bisogno di aiuto" (visibile solo per i cittadini)
                if (!isRescuer)
                  Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Ho bisogno di aiuto",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: labelFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Checkbox(
                            value: _needsHelp,
                            onChanged: (bool? newValue) {
                              // Aggiorna lo stato locale del checkbox.
                              setState(() {
                                _needsHelp = newValue ?? false;
                              });
                            },
                            shape: const CircleBorder(),
                            checkColor: Colors.white,
                            activeColor: accentColor,
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              if (states.contains(WidgetState.selected)) {
                                return accentColor;
                              }
                              return Colors.white;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ), // fine checkbox

                const SizedBox(height: 20.0),

                // Bottone di invio
                SizedBox(
                  width: double.infinity,
                  height: isWideScreen ? 70 : 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.emergencyButtonRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    // Disabilita il bottone se il provider è in stato di caricamento.
                    onPressed: reportProvider.isLoading
                        ? null
                        : () => _sendEmergency(reportProvider),
                    child: reportProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "INVIA EMERGENZA",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecificEmergency(BuildContext context, bool isWideScreen) {
    return SizedBox(
      width: isWideScreen ? 500 : double.infinity,
      child: EmergencyDropdownMenu(
        value: _selectedEmergency,
        hintText: "Segnala il tipo di emergenza",
        items: [
          EmergencyItem(label: "Terremoto", icon: Icons.waves),
          EmergencyItem(label: "Incendio", icon: Icons.local_fire_department),
          EmergencyItem(label: "Tsunami", icon: Icons.water),
          EmergencyItem(label: "Alluvione", icon: Icons.flood),
          EmergencyItem(label: "Malessere", icon: Icons.medical_services),
          EmergencyItem(label: "Bomba", icon: Icons.warning),
        ],
        onSelected: (item) {
          // Callback quando un elemento è selezionato.
          setState(() {
            _selectedEmergency =
                item; // Salva l'oggetto selezionato nello stato.
          });
          // Feedback rapido tramite SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Selezionato: ${item.label}"),
              backgroundColor: Colors.black,
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar({required String content, required Color color}) {
    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar(); // Nasconde la SnackBar precedente.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
