import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/widgets/emergency_item.dart';
import 'package:frontend/providers/report_provider.dart';

// Schermata Report Specifico
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _needsHelp = false;
  final TextEditingController _descriptionController = TextEditingController();
  EmergencyItem? _selectedEmergency;

  // Funzione per mandare l'emergenza collegata al Provider
  Future<void> _sendEmergency(ReportProvider reportProvider) async {
    final String description = _descriptionController.text;

    if (_selectedEmergency == null) {
      _showSnackBar(
        content: 'Inserisci un\'emergenza da segnalare',
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

    // Chiamata al Provider
    // Passiamo la stringa del tipo (es. "Incendio") e la descrizione
    // NOTA: La logica SMS/GPS deve essere gestita dentro reportProvider.sendReport
    bool success = await reportProvider.sendReport(
        _selectedEmergency!.label,
        description
    );

    // Gestione esito
    if (success && mounted) {
      _showSnackBar(content: 'Emergenza segnalata con successo', color: Colors.green);

      // Reset campi dopo invio
      setState(() {
        _selectedEmergency = null;
        _descriptionController.clear();
        _needsHelp = false;
      });

      // Se vuoi tornare alla home decommenta la riga sotto:
      // Navigator.of(context).pop();
    } else if (mounted) {
      _showSnackBar(
          content: 'Errore invio segnalazione. Riprova.',
          color: ColorPalette.emergencyButtonRed
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    // Accesso ai Provider
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final reportProvider = context.watch<ReportProvider>(); // Per lo stato isLoading

    Color bgColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundMidBlue;
    Color cardColor = isRescuer
        ? ColorPalette.cardDarkOrange
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

                const SizedBox(height: 20.0),

                // Tipi di segnalazione
                SizedBox(
                  height: 60,
                  child: _buildSpecificEmergency(context, isWideScreen),
                ),

                isRescuer ? const SizedBox(height: 40.0) : const SizedBox(height: 20.0),

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

                // TextArea per la descrizione
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

                // checkbox per la richiesta di aiuto (visibile solo all'utente, non al soccorritore)
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
                  ),

                const SizedBox(height: 20.0),

                // pulsante che manda e crea l'emergenza
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
                    // Disabilita se sta caricando (usando lo stato del provider)
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // dropdown menu per la selezione dell'emergenza
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
          setState(() {
            _selectedEmergency = item;
          });

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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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