import 'package:flutter/material.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Widget di Scorrimento per conferma
// Un componente UI che richiede uno swipe orizzontale completo per eseguire una callback.
class SwipeToConfirm extends StatefulWidget {
  final double height;
  final double width;
  final VoidCallback onConfirm;

  // Parametri di personalizzazione
  final Widget? thumb; // Widget custom per la freccia
  final String text; // Testo personalizzabile
  final TextStyle? textStyle; // Stile testo personalizzabile
  final Color? sliderColor; // Colore della freccia
  final Color? backgroundColor; // Colore dello sfondo della barra
  final Color? iconColor; // Colore dell'icona
  final bool isDisabled;

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
    this.isDisabled = false,
  });

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm> {
  // Posizione orizzontale attuale del dito
  double position = 0;
  bool confirmed = false;

  // Variabili per la colorazione di stato disabilitato
  final Color disabledThumbColor = Colors.black54;
  final Color disabledTrackColor = Colors.black45;

  @override
  Widget build(BuildContext context) {
    // Larghezza massima scorribile
    final double maxDragDistance = widget.width - widget.height;
    final bool isEnabled = !widget.isDisabled;

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
                  style:
                      widget.textStyle ??
                      TextStyle(
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
            duration: const Duration(
              milliseconds: 80,
            ), // Breve animazione per il reset
            left: position,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              // Aggiornamento della posizione durante il trascinamento
              onHorizontalDragUpdate: isEnabled ? (details) {
                if (confirmed) return;

                setState(() {
                  // Aggiunge la distanza trascinata alla posizione attuale
                  position += details.delta.dx;
                  if (position < 0) position = 0;
                  if (position > maxDragDistance) {
                    position = maxDragDistance;
                  }
                });
              }:null,
              onHorizontalDragEnd: isEnabled ? (_) {
                if (confirmed) return;

                // Se la posizione è vicina al massimo, conferma l'azione
                if (position >= maxDragDistance - 5) {
                  setState(() {
                    confirmed = true;
                  });
                  widget.onConfirm();
                } else {
                  // Se non è arrivato alla fine, resetta la posizione all'inizio
                  setState(() {
                    position = 0;
                  });
                }
              }:null,

              // Contenuto visivo del Thumb
              child: SizedBox(
                height: widget.height,
                width: widget.height,
                child:
                    widget.thumb ??
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isEnabled ? (widget.sliderColor ?? ColorPalette.primaryBrightRed) : disabledThumbColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: widget.iconColor ?? Colors.white,
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
