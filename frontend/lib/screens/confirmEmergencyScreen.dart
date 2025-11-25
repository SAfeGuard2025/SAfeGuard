import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ConfirmEmergencyScreen extends StatelessWidget {
  const ConfirmEmergencyScreen({super.key});

  static const brightRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    // Il Container principale avvolge tutto il corpo per impostare il colore di sfondo
    return Container(
      color: brightRed,
      child: Scaffold(
        backgroundColor: Colors
            .transparent, // Rende trasparente lo Scaffold per mostrare il Container scuro
        // --- BODY: Il contenuto centrale della pagina ---
        body: SafeArea(
          child: SingleChildScrollView(
            // Permette lo scroll se lo schermo è piccolo
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Separatore
                  const SizedBox(height: 10),
                  //Immagine SOS
                  _buildSosImage(),
                  const SizedBox(height: 10),
                  //Scritta CONFERMA SOS
                  _buildConfirmText(),
                  const SizedBox(height: 10),
                  //Scritta SWIPE PER MANDARE LA TUA POSIZIONE
                  _buildSwipeToText(),
                  const SizedBox(height: 10),
                  //Slider
                  _buildSwipe(context),
                  const SizedBox(height: 10),
                  //Scritta ricorda che il procurato allarme è reato
                  _buildReminderText(),
                  const SizedBox(height: 10),
                  _buildGoBackButton(context),
                ],
              ),
            ),
          ),
        ),

        //Fine della parte centrale della pagina
      ),
    );
  } //Fine del widget build, ora partono le dichiarazioni dei metodi per i widget

  Widget _buildSosImage() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage('assets/sosbutton.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildConfirmText() {
    return Text(
      "Conferma SOS",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 55,
      ),
    );
  }

  Widget _buildSwipeToText() {
    return Text(
      "Swipe per mandare la tua \nposizione e allertare i soccorritori",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );
  }

  Widget _buildSwipe(BuildContext context) {
    return Center(
      child: SwipeToConfirm(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 64,

        // quando arriva a fine swipe
        onConfirm: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("SOS attivato!"),
              duration: Duration(seconds: 1),
            ),
          );
        },

        // freccia (thumb)
        thumb: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: Image.asset(
            'assets/arrow.png', // qui il tuo PNG
            scale: 4,
          ),
        ),

        // barra (background)
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8B1D1D),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Center(
            child: Text(
              "Slide per confermare",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderText() {
    return Text(
      "Ricorda che il procurato allarme verso le autorità è\nperseguibile per legge ai sensi dell'art. 658 del c.p.",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.normal,
        fontSize: 15,
      ),
    );
  }

  Widget _buildGoBackButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("SOS annullato!"),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: const Text(
        "Annulla",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }
}

//Implementazione dello swipe, senza bisogno di mettere la classe principale
//stateful
class SwipeToConfirm extends StatefulWidget {
  final double height;
  final double width;
  final VoidCallback onConfirm;
  final Widget thumb; // la freccia
  final Widget background; // la barra rossa

  const SwipeToConfirm({
    super.key,
    required this.onConfirm,
    required this.thumb,
    required this.background,
    this.height = 60,
    required this.width,
  });

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm> {
  double position = 0;
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          /// 🔴 BACKGROUND DELLA BARRA (PNG o Container)
          Positioned.fill(child: widget.background),

          /// 👉 THUMB/FRECCIA CHE SI MUOVE
          AnimatedPositioned(
            duration: const Duration(milliseconds: 80),
            left: position,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  position += details.delta.dx;
                  if (position < 0) position = 0;
                  if (position > widget.width - widget.height) {
                    position = widget.width - widget.height;
                    if (!confirmed) {
                      confirmed = true;
                      widget.onConfirm();
                    }
                  }
                });
              },
              onHorizontalDragEnd: (_) {
                if (!confirmed) {
                  setState(() {
                    position = 0;
                  });
                }
              },
              child: SizedBox(
                height: widget.height,
                width: widget.height,
                child: widget.thumb,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
