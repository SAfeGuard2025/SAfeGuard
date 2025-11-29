import 'package:flutter/material.dart';
import 'package:frontend/ui/style/color_palette.dart';

class SwipeToConfirm extends StatefulWidget {
  final double height;
  final double width;
  final VoidCallback onConfirm;
  final Widget? thumb; // La freccia
  final String text;            // Testo personalizzabile
  final TextStyle? textStyle;   // Stile testo personalizzabile
  final Color? sliderColor;     // Colore freccia
  final Color? backgroundColor; // Colore sfondo barra
  final Color? iconColor;       // Colore icona

  const SwipeToConfirm({
    super.key,
    required this.onConfirm,
    required this.width,
    this.height = 60,
    this.thumb,
    this.text = "Slide per confermare",
    this.textStyle,
    this.sliderColor,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm> {
  double position = 0;
  bool confirmed = false;

  @override
  Widget build(BuildContext context) {
    // Larghezza massima scorribile
    final double maxDragDistance = widget.width - widget.height;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background della barra
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? ColorPalette.swipeDarkRed,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
              child: Center(
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  // MODIFICA QUI:
                  // Se non passi uno stile personalizzato, usa quello di default.
                  // Ho impostato il font size al 30% dell'altezza dello slider.
                  // Esempio: altezza 70 -> font 21 | altezza 80 -> font 24
                  style: widget.textStyle ?? TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.height * 0.25,
                  ),
                ),
              ),
            ),
          ),

          // Thumb (Freccia che si muove)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 80),
            left: position,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (confirmed) return;

                setState(() {
                  position += details.delta.dx;
                  if (position < 0) position = 0;
                  if (position > maxDragDistance) {
                    position = maxDragDistance;
                  }
                });
              },
              onHorizontalDragEnd: (_) {
                if (confirmed) return;

                if (position >= maxDragDistance - 5) {
                  setState(() {
                    confirmed = true;
                  });
                  widget.onConfirm();
                } else {
                  setState(() {
                    position = 0;
                  });
                }
              },
              child: SizedBox(
                height: widget.height,
                width: widget.height,
                child: widget.thumb ??
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.sliderColor ?? Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: widget.iconColor ?? Colors.white,
                        // L'icona scala in base all'altezza dello slider (60%)
                        size: widget.height * 0.6,
                      ),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}