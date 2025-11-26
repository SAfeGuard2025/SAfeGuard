import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/swipe_to_confirm.dart';

class ConfirmEmergencyScreen extends StatelessWidget {
  const ConfirmEmergencyScreen({super.key});

  static const Color brightRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brightRed,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildSosImage(),
                const SizedBox(height: 10),
                const Text(
                  "Conferma SOS",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 55,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Swipe per mandare la tua \nposizione e allertare i soccorritori",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 40),

                Center(
                  child: SwipeToConfirm(
                    //Lo slider prende l'85% della larghezza della pagina
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 70,

                    onConfirm: () {
                      Navigator.of(context).pop(); // Chiude la schermata
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("SOS INVIATO!"),
                          backgroundColor: Colors.black,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),
                const Text(
                  "Ricorda che il procurato allarme verso le autorità è\nperseguibile per legge ai sensi dell'art. 658 del c.p.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Annulla",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
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

  Widget _buildSosImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('assets/sosbutton.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
