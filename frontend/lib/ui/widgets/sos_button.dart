import 'package:flutter/material.dart';
import 'package:frontend/ui/style/color_palette.dart';

class SosButton extends StatelessWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcola la dimensione basandosi sul lato più corto disponibile
        final double size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Container(
          width: size,
          height: size,

          // 1. BORDO GRIGIO (Esterno)
          decoration: BoxDecoration(
            color: Colors.grey.shade300, // Grigio chiaro metallico
            shape: BoxShape.circle,
          ),
          // Questo padding determina lo spessore del bordo grigio
          padding: EdgeInsets.all(size * 0.015),

          child: Container(
            // 2. ANELLO ROSSO
            decoration: const BoxDecoration(
              color: ColorPalette.primaryBrightRed, // Rosso brillante
              shape: BoxShape.circle,
            ),
            // Questo padding determina lo spessore dell'anello rosso
            padding: EdgeInsets.all(size * 0.04),

            child: Container(
              // 3. BORDINO BIANCO
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              // Questo padding determina lo spessore del bordino bianco sottile
              padding: EdgeInsets.all(size * 0.007),

              child: Container(
                // 4. SFONDO INTERNO
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Uso un gradiente per renderlo "diverso" e dare effetto 3D
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      // Parte da un rosso leggermente più scuro del primary
                      ColorPalette.sosDarkRed,
                      // Finisce in un rosso molto scuro/bordeaux
                      Colors.red.shade700,
                    ],
                  ),
                  boxShadow: [
                    // Aggiunta un'ombra interna leggera per staccarlo dal bordo bianco
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Text(
                  'SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.28,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
