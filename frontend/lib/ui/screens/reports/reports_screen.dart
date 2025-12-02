import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/widgets/emergency_item.dart';

// Schermata Report Specifico
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // andrebbe la repository dell'emergenza (?)

  bool _isLoading = false;
  bool _needsHelp = false;

  final TextEditingController _descriptionController =
  TextEditingController(); // per salvarmi il testo della descrizione

  EmergencyItem?
  _selectedEmergency; // se vuoi sostituire con String, devi mettere item.label a: (fai ctrl + f) _selectedEmergency = item;

  // funzione per mandare l'emergenza (da finire)
  Future<void> _sendEmergency() async {
    // andrebbero anche i dati della posizione

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

    _showSnackBar(content: 'Emergenza segnalata', color: Colors.green);
    // mettere che va alla home alla creazione della segnalazione
    return;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 700;

    final isRescuer = context.watch<AuthProvider>().isRescuer;

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

                isRescuer ? SizedBox(height: 40.0) : SizedBox(height: 20.0),

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

                // checkbox per la richiesta di aiuto (visibile solo all'utente)
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
                  ), // fine checkbox

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
                    onPressed: _sendEmergency,
                    child: _isLoading
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
            _selectedEmergency =
                item; // mi salvo l'emergency item (item.label se vuoi una stringa)
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Selezionato: ${item.label}"),
              backgroundColor: Colors.black,
            ),
          );
        },
      ),
    );
  }

  // metodo per vedere se l'emergenza è stata mandata o no
  void _showSnackBar({required String content, required Color color}) {
    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar(); // nasconde la notifica attuale

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