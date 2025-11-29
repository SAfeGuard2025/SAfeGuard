import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/swipe_to_confirm.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata di Conferma Emergenza (SOS)
// Presenta un'interfaccia ad alto contrasto (rosso) e richiede uno swipe per confermare l'allarme.
class ConfirmEmergencyScreen extends StatelessWidget {
  const ConfirmEmergencyScreen({super.key});

  static const Color brightRed = ColorPalette.primaryBrightRed;

  @override
  Widget build(BuildContext context) {
    // 1. Variabili per la responsività
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final bool isWideScreen = screenWidth > 600;

    // Dimensione dei font dinamiche
    final double titleSize = isWideScreen ? 60 : 45;
    final double subTitleSize = isWideScreen ? 26 : 20;

    // Testo legale: 14 su mobile -> 20 su tablet
    final double legalTextSize = isWideScreen ? 20 : 14;

    // Tasto Annulla: 24 su mobile -> 35 su tablet
    final double cancelTextSize = isWideScreen ? 35 : 24;

    // Larghezza slider
    final double sliderWidth = math.min(screenWidth * 0.85, 500.0);

    return Scaffold(
      backgroundColor: brightRed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // 1. Immagine SOS
              Expanded(
                flex: 4,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _buildSosImage(),
                  ),
                ),
              ),

              SizedBox(height: isWideScreen ? 40 : 20),

              // 2. Testi
              Column(
                children: [
                  Text(
                    "Conferma SOS",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: titleSize,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Swipe per mandare la tua \nposizione e allertare i soccorritori",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: subTitleSize,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              // 3. Slider
              Center(
                child: SwipeToConfirm(
                  width: sliderWidth,
                  height: isWideScreen ? 80 : 70,
                  onConfirm: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("SOS INVIATO!"),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                ),
              ),

              const Spacer(flex: 1),

              // 4. Footer
              Column(
                children: [
                  Text(
                    "Ricorda che il procurato allarme verso le autorità è\nperseguibile per legge ai sensi dell'art. 658 del c.p.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      fontSize: legalTextSize,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Annulla",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: cancelTextSize,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSosImage() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/sosbutton.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}