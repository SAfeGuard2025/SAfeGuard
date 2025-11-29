import 'package:flutter/material.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Modello Dati per gli elementi di Emergenza
class EmergencyItem {
  final String label;
  final IconData icon;

  EmergencyItem({required this.label, required this.icon});
}

// Widget del Menu a Discesa di Emergenza
class EmergencyDropdownMenu extends StatefulWidget {
  final List<EmergencyItem> items;
  // Callback per notificare la selezione dell'elemento
  final ValueChanged<EmergencyItem> onSelected;

  const EmergencyDropdownMenu({
    super.key,
    required this.items,
    required this.onSelected,
  });

  @override
  createState() => _EmergencyDropdownMenuState();
}

class _EmergencyDropdownMenuState extends State<EmergencyDropdownMenu> {
  // Chiave globale per trovare la posizione e le dimensioni del pulsante nel widget tree
  final GlobalKey _buttonKey = GlobalKey();
  // Oggetto che gestisce il contenuto del menu in sovrapposizione
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  // Altezza stimata dell'elemento singolo (lista + padding)
  static const double _itemHeight = 45.0;
  // Altezza del solo pulsante rosso "Emergenza specifica" + relativo padding
  static const double _fixedButtonHeight = 70.0;

  @override
  void dispose() {
    // Rimuove l'OverlayEntry se è attivo, prevenendo memory leak
    _overlayEntry?.remove();
    super.dispose();
  }

  // Logica di apertura e chiusura del Menu
  void _toggleMenu() {
    if (_isOpen) {
      // Chiusura del menu
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      // Apertura del menu
      final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
      // Posizione globale e dimensione del pulsante attuale
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // Calcola l'altezza necessaria per tutti gli elementi e l'intestazione fissa
      final double itemsTotalHeight = _itemHeight * widget.items.length;
      const double safetyMargin = 30.0;
      final double menuHeight = itemsTotalHeight + _fixedButtonHeight + safetyMargin;

      // Crea e inserisce l'OverlayEntry
      _overlayEntry = _createOverlayEntry(offset, size, menuHeight);
      Overlay.of(context).insert(_overlayEntry!);
    }
    // Aggiorna lo stato di apertura
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  // Costruzione dell'OverlayEntry
  OverlayEntry _createOverlayEntry(Offset offset, Size size, double menuHeight) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          // Posiziona il menu sopra il pulsante, sottraendo l'altezza del menu all'offset Y
          top: offset.dy - menuHeight,
          left: offset.dx,
          width: size.width,
          child: Material(
            elevation: 4.0,
            color: Colors.transparent,
            child: _buildDropdownContent(menuHeight),
          ),
        );
      },
    );
  }

  // Contenuto del Menu a discesa
  Widget _buildDropdownContent(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0, bottom: 16.0),

      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Bottone Fisso "Emergenza specifica" (in alto)
          Container(
            height: 55,
            margin: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              onPressed: () {
                // Azione per l'emergenza specifica
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.emergencyButtonRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Emergenza specifica", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Colors.grey),

          // Lista dinamica degli elementi
          ...widget.items.map((item) => InkWell(
            onTap: () {
              widget.onSelected(item);
              _toggleMenu(); // Chiudi il menu dopo la selezione
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(child: Text(item.label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500))),
                  Icon(item.icon, size: 30, color: Colors.grey.shade700),
                ],
              ),
            ),
          )).toList().reversed, // Inversione per l'ordine visuale dal basso verso l'alto
          const Spacer(),
        ],
      ),
    );
  }

  // Costruzione del Pulsante/Trigger
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey, // Assegna la chiave per il calcolo della posizione
      onTap: _toggleMenu,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(16.0),
            bottomRight: const Radius.circular(16.0),
            topLeft: _isOpen ? Radius.zero : const Radius.circular(16.0),
            topRight: _isOpen ? Radius.zero : const Radius.circular(16.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Segnala il tipo di emergenza",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            // Icona di freccia che cambia in base allo stato
            Icon(
              _isOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              size: 24,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}