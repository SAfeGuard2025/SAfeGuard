import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/home/confirm_emergency_screen.dart';

class SosButton extends StatefulWidget {
  final double size;

  const SosButton({super.key, required this.size});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurazione pulsazione
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // --- AZIONE AL CLICK ---
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ConfirmEmergencyScreen(),
          ),
        );
      },

      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,

              // --- DECORAZIONE (Senza Immagini) ---
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                // 1. Gradiente per effetto 3D (Luce in alto a sx, ombra in basso a dx)
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF5252), // Rosso Chiaro (Luce)
                    Color(0xFFD32F2F), // Rosso Standard
                    Color(0xFFB71C1C), // Rosso Scuro (Ombra)
                  ],
                ),

                // 2. Bordo bianco
                border: Border.all(
                    color: Colors.white,
                    width: 5
                ),

                // 3. Ombre
                boxShadow: [
                  // Ombra "Glow" che pulsa (rossa)
                  BoxShadow(
                    color: const Color(0xFFE53935).withOpacity(0.6),
                    blurRadius: 30 * _scaleAnimation.value, // Sfocatura variabile
                    spreadRadius: 10 * _scaleAnimation.value, // Espansione variabile
                  ),
                  // Ombra "Fisica" sotto il bottone (nera)
                  const BoxShadow(
                    color: Colors.black45,
                    blurRadius: 15,
                    offset: Offset(0, 10),
                  ),
                ],
              ),

              // --- TESTO CENTRALE ---
              child: const Center(
                child: Text(
                  "SOS",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900, // Molto grassetto
                      letterSpacing: 3.0,
                      // Ombra del testo per staccarlo dallo sfondo
                      shadows: [
                        Shadow(
                            blurRadius: 5,
                            color: Colors.black38,
                            offset: Offset(2, 2)
                        )
                      ]
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}