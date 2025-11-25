import 'package:flutter/material.dart';

class SwipeToConfirm extends StatefulWidget {
  final double height;
  final double width;
  final VoidCallback onConfirm;
  final Widget? thumb; // La freccia (opzionale)
  final Widget? background; // La barra rossa (opzionale)

  const SwipeToConfirm({
    super.key,
    required this.onConfirm,
    this.thumb,
    this.background,
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
    // Calcoliamo la larghezza massima scorribile
    final double maxDragDistance = widget.width - widget.height;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          /// 🔴 BACKGROUND DELLA BARRA
          Positioned.fill(
            child: widget.background ??
                Container(
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

          /// 👉 THUMB/FRECCIA CHE SI MUOVE
          AnimatedPositioned(
            duration: const Duration(milliseconds: 80),
            left: position,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (confirmed) return; // Se già confermato, blocca

                setState(() {
                  position += details.delta.dx;
                  // Blocca a sinistra (0)
                  if (position < 0) position = 0;
                  // Blocca a destra (maxDragDistance)
                  if (position > maxDragDistance) {
                    position = maxDragDistance;
                  }
                });
              },
              onHorizontalDragEnd: (_) {
                if (confirmed) return;

                // Se è arrivato in fondo (con un margine di tolleranza di 5px)
                if (position >= maxDragDistance - 5) {
                  setState(() {
                    confirmed = true;
                  });
                  widget.onConfirm();
                } else {
                  // Torna indietro se non ha finito (effetto elastico)
                  setState(() {
                    position = 0;
                  });
                }
              },
              child: SizedBox(
                height: widget.height,
                width: widget.height, // Il thumb è quadrato
                child: widget.thumb ??
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30
                      ),
                      // Se vuoi usare l'immagine PNG, usa questo invece dell'Icon:
                      // child: Image.asset('assets/arrow.png', scale: 4),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}