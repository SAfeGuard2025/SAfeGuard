import 'package:flutter/material.dart';
import 'package:frontend/ui/style/color_palette.dart';

enum BubbleType {
  type1, // Per RegistrationScreen (backgroundBubbles1)
  type2, // Per LoginScreen (backgroundBubbles2)
  type3, // Per Email/Phone Login/Register (backgroundBubbles3)
}

class BubbleBackground extends StatelessWidget {
  final BubbleType type;
  final Widget? child;

  const BubbleBackground({super.key, required this.type, this.child});

  @override
  Widget build(BuildContext context) {
    // Colore di sfondo base del Container
    // Type 1 e 2 hanno sfondo bianco/trasparente nelle immagini originali
    // Type 3 ha sfondo blu scuro
    Color backgroundColor = (type == BubbleType.type3)
        ? ColorPalette.backgroundDeepBlue
        : Colors.white;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: CustomPaint(
        painter: _BubblePainter(type: type),
        child: child,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final BubbleType type;

  _BubblePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Colori derivati dalle immagini
    // Nota: Uso ColorPalette.backgroundDeepBlue come base, ma ne modifico
    // l'opacità o la luminosità per creare i livelli di profondità.
    final Color mainBlue = ColorPalette.backgroundDeepBlue;
    final Color lighterBlue = Color(
      0xFF1E3A5F,
    ); // Un blu leggermente più chiaro per gli sfondi
    final Color darkerBlue = Color(
      0xFF0D1B2A,
    ); // Un blu quasi nero per il primo piano

    final Paint paintMain = Paint()
      ..color = mainBlue
      ..style = PaintingStyle.fill;
    final Paint paintLight = Paint()
      ..color = lighterBlue
      ..style = PaintingStyle.fill;
    final Paint paintDark = Paint()
      ..color = darkerBlue
      ..style = PaintingStyle.fill;

    // Vernice specifica per il Type 3 (bolle su sfondo scuro)
    final Paint paintType3Overlay = Paint()
      ..color = Colors.white
          .withValues(alpha: 0.05) // Molto sottile
      ..style = PaintingStyle.fill;

    switch (type) {
      case BubbleType.type1:
        _drawType1(canvas, paintMain, paintDark, w, h);
        break;
      case BubbleType.type2:
        _drawType2(canvas, paintMain, paintLight, paintDark, w, h);
        break;
      case BubbleType.type3:
        _drawType3(canvas, paintType3Overlay, w, h);
        break;
    }
  }

  // REPLICA backgroundBubbles1.png (RegistrationScreen)
  // Una grande curva a destra, una grande a sinistra e una scura in basso.
  void _drawType1(
    Canvas canvas,
    Paint paintMain,
    Paint paintDark,
    double w,
    double h,
  ) {
    // 1. Grande cerchio sullo sfondo (destra)
    canvas.drawCircle(
      Offset(w * 0.8, h * 0.65), // Centro spostato in alto a destra
      w * 0.8, // Raggio enorme
      paintMain..color = paintMain.color.withValues(alpha: 0.8),
    );

    // 2. Cerchio principale (sinistra)
    canvas.drawCircle(
      Offset(0, h * 0.85), // Centro sul bordo sinistro, in basso
      w * 0.9,
      paintMain..color = ColorPalette.backgroundDeepBlue,
    );

    // 3. Cerchio scuro in primissimo piano (basso)
    canvas.drawCircle(
      Offset(w * 0.5, h * 1.35), // Centro molto sotto lo schermo
      w * 1.1,
      paintDark,
    );
  }

  // REPLICA backgroundBubbles2.png (LoginScreen)
  // Tre colline distinte.
  void _drawType2(
    Canvas canvas,
    Paint paintMain,
    Paint paintLight,
    Paint paintDark,
    double w,
    double h,
  ) {
    // 1. Collina posteriore (Destra) - Quella più chiara/alta
    // Modifichiamo leggermente il colore per differenziarla
    canvas.drawCircle(
      Offset(w * 0.9, h * 0.75), // Centro fuori a destra
      w * 0.9, // Raggio grande
      paintLight,
    );

    // 2. Collina media (Sinistra) - Quella blu standard
    canvas.drawCircle(
      Offset(0, h * 0.85), // Centro sul bordo sinistro
      w * 0.85,
      paintMain,
    );

    // 3. Collina frontale (Basso Centro) - Quella molto scura
    canvas.drawCircle(
      Offset(w * 0.3, h * 1.3), // Centro molto in basso a sinistra
      w * 1.0,
      paintDark,
    );
  }

  // REPLICA backgroundBubbles3.png (Pagine interne)
  // Sfondo scuro con archi sottili appena visibili.
  void _drawType3(Canvas canvas, Paint paintOverlay, double w, double h) {
    // Arco in alto a sinistra
    canvas.drawCircle(Offset(0, 0), w * 0.7, paintOverlay);

    // Arco in basso a destra
    canvas.drawCircle(Offset(w, h), w * 0.8, paintOverlay);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
