import 'package:flutter/material.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Modello Dati per gli elementi di Emergenza (Presumibilmente definito altrove)
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
  // Aggiunto per mostrare il valore selezionato nel pulsante trigger
  final EmergencyItem? value;
  // Aggiunto per il testo segnaposto
  final String hintText;

  const EmergencyDropdownMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.value,
    this.hintText = "Seleziona",
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
  // Altezza del solo pulsante fisso interno
  static const double _fixedButtonHeight = 70.0;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  // Logica di apertura e chiusura del Menu
  void _toggleMenu() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      final RenderBox renderBox =
          _buttonKey.currentContext!.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // Calcola l'altezza massima necessaria per l'Overlay
      final double itemsTotalHeight = _itemHeight * widget.items.length;
      final double menuHeight = itemsTotalHeight + _fixedButtonHeight;

      _overlayEntry = _createOverlayEntry(offset, size, menuHeight);
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  // Costruzione dell'OverlayEntry
  OverlayEntry _createOverlayEntry(
    Offset offset,
    Size size,
    double menuHeight,
  ) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          // Posiziona il menu sotto il pulsante trigger
          top: offset.dy + size.height,
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
      // Non è necessario usare l'altezza fissa qui,
      // Column.mainAxisSize.min gestisce meglio lo spazio
      decoration: BoxDecoration(
        color: Colors.white,
        // Bordi arrotondati solo in basso
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.3,
            ), // Usato withOpacity per coerenza
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: 16.0, // Aumentato un po' il padding superiore
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min, // Adatta la colonna al contenuto
        children: <Widget>[
          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 5.0), // Piccolo spazio
          // Lista dinamica degli elementi
          ...widget.items
              .map(
                (item) => InkWell(
                  onTap: () {
                    widget.onSelected(item);
                    _toggleMenu(); // Chiudi il menu dopo la selezione
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(item.icon, size: 30, color: Colors.grey.shade700),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
          // Rimosso Spacer()
        ],
      ),
    );
  }

  // Costruzione del Pulsante/Trigger
  @override
  Widget build(BuildContext context) {
    final String labelText = widget.value?.label ?? widget.hintText;

    return GestureDetector(
      key: _buttonKey,
      onTap: _toggleMenu,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          // BorderRadius del pulsante Trigger
          borderRadius: BorderRadius.only(
            // Top Left e Top Right sono sempre arrotondati
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            // Bottom Left e Bottom Right piatti SOLO quando il menu è aperto
            bottomLeft: _isOpen ? Radius.zero : const Radius.circular(16.0),
            bottomRight: _isOpen ? Radius.zero : const Radius.circular(16.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labelText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.value != null
                    ? Colors.black
                    : Colors.grey.shade600, // Colore hint
              ),
            ),
            // Freccia per l'apertura verso il basso
            Icon(
              _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 24,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
