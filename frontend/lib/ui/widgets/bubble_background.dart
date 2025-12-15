import 'package:flutter/material.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Enum che definisce i diversi layout di bolle disponibili.
enum BubbleType {
  type1, // Per RegistrationScreen Portrait
  type2, // Per LoginScreen Portrait
  type3, // Per Email/Phone Login/Register (sfondo scuro)
  type4, // Per RegistrationScreen e LoginScreen in modalità landscape
}

// Widget principale: Funge da contenitore e chiama il pittore personalizzato.
class BubbleBackground extends StatelessWidget {
  final BubbleType type;
  final Widget? child;

  const BubbleBackground({super.key, required this.type, this.child});

  @override
  Widget build(BuildContext context) {
    // Determina il colore di sfondo del Container base.
    // Solo type3 (pagine interne) ha uno sfondo blu scuro, gli altri hanno sfondo bianco.
    Color backgroundColor = (type == BubbleType.type3)
        ? ColorPalette.backgroundDeepBlue
        : Colors.white;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      // CustomPaint è il widget che delega il disegno a _BubblePainter.
      child: CustomPaint(
        painter: _BubblePainter(type: type),
        child: child, // Posiziona il contenuto sopra il disegno.
      ),
    );
  }
}

// Pittore Personalizzato: Contiene la logica di disegno geometrico delle bolle.
class _BubblePainter extends CustomPainter {
  final BubbleType type;

  _BubblePainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Colori presi dalla palette
    final Color mainBlue = ColorPalette.backgroundDeepBlue;
    final Color lighterBlue = const Color(0xFF1E3A5F); // Blu chiaro
    final Color darkerBlue = const Color(0xFF0D1B2A); // Blu scuro

    // Definisce i pennelli
    final Paint paintMain = Paint()
      ..color = mainBlue
      ..style = PaintingStyle.fill;

    final Paint paintLight = Paint()
      ..color = lighterBlue
      ..style = PaintingStyle.fill;

    final Paint paintDark = Paint()
      ..color = darkerBlue
      ..style = PaintingStyle.fill;

    final Paint paintType3Overlay = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Switch per selezionare la funzione di disegno appropriata in base al BubbleType.
    switch (type) {
      case BubbleType.type1:
        _drawType1(canvas, paintMain, paintLight, paintDark, w, h);
        break;
      case BubbleType.type2:
        _drawType2(canvas, paintMain, paintLight, paintDark, w, h);
        break;
      case BubbleType.type3:
        _drawType3(canvas, paintType3Overlay, w, h);
        break;
      case BubbleType.type4:
        _drawType4(canvas, paintMain, paintLight, paintDark, w, h);
        break;
    }
  }

  // TYPE 1: Registration Portrait
  void _drawType1(
    Canvas canvas,
    Paint paintMain,
    Paint paintLight,
    Paint paintDark,
    double w,
    double h,
  ) {
    // 1. Grande cerchio a destra (colore chiaro).
    canvas.drawCircle(
      Offset(w * 0.8, h * 0.65),
      w * 0.8,
      paintLight, // <--- CAMBIATO QUI (Era paintMain con opacità)
    );

    // 2. Cerchio principale a sinistra (colore principale).
    canvas.drawCircle(Offset(0, h * 0.85), w * 0.9, paintMain);

    // 3. Cerchio scuro in basso (colore scuro).
    canvas.drawCircle(Offset(w * 0.5, h * 1.35), w * 1.1, paintDark);
  }

  // TYPE 2: Login Portrait
  void _drawType2(
    Canvas canvas,
    Paint paintMain,
    Paint paintLight,
    Paint paintDark,
    double w,
    double h,
  ) {
    canvas.drawCircle(Offset(w * 0.9, h * 0.75), w * 0.9, paintLight);
    canvas.drawCircle(Offset(0, h * 0.85), w * 0.85, paintMain);
    canvas.drawCircle(Offset(w * 0.3, h * 1.3), w * 1.0, paintDark);
  }

  // TYPE 3: Pagine interne (Sfondo scuro)
  void _drawType3(Canvas canvas, Paint paintOverlay, double w, double h) {
    canvas.drawCircle(Offset(0, 0), w * 0.7, paintOverlay);
    canvas.drawCircle(Offset(w, h), w * 0.8, paintOverlay);
  }

  // TYPE 4: Landscape
  void _drawType4(
    Canvas canvas,
    Paint paintMain,
    Paint paintLight,
    Paint paintDark,
    double w,
    double h,
  ) {
    canvas.drawCircle(Offset(w * 0.75, h * 0.1), h * 1.1, paintLight);
    canvas.drawCircle(
      Offset(w * 0.85, h * 0.9),
      h * 1.0,
      paintMain..color = ColorPalette.backgroundDeepBlue,
    );
    canvas.drawCircle(Offset(w * 1.0, h * 1.0), h * 0.8, paintDark);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
