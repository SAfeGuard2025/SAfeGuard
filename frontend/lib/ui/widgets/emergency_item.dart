import 'package:flutter/material.dart';

class EmergencyItem {
  final String label;
  final IconData icon;

  EmergencyItem({required this.label, required this.icon});
}

class EmergencyDropdownMenu extends StatefulWidget {
  final List<EmergencyItem> items;
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
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  // Altezza stimata dell'elemento singolo (lista + padding)
  static const double _itemHeight = 45.0;
  // Altezza del solo pulsante rosso "Emergenza specifica" + relativo padding
  static const double _fixedButtonHeight = 70.0;

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;

      // Altezza totale dei 6 elementi (6 * 45.0) = 270.0
      final double itemsTotalHeight = _itemHeight * widget.items.length;

      // Aggiungiamo un margine di sicurezza di circa 30 pixel.
      const double safetyMargin = 30.0;

      // Nuova altezza totale stimata
      final double menuHeight = itemsTotalHeight + _fixedButtonHeight + safetyMargin;

      _overlayEntry = _createOverlayEntry(offset, size, menuHeight);
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  OverlayEntry _createOverlayEntry(Offset offset, Size size, double menuHeight) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
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
          Container(
            height: 55,
            margin: const EdgeInsets.only(bottom: 10.0),
            child: ElevatedButton(
              onPressed: () {
                // Azione per l'emergenza specifica
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
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

          ...widget.items.map((item) => InkWell(
            onTap: () {
              widget.onSelected(item);
              _toggleMenu();
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
          )).toList().reversed,
          const Spacer(),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: _toggleMenu,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: _isOpen ? Colors.white : Colors.white,
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
                color: _isOpen ? Colors.black : Colors.black,
              ),
            ),
            Icon(
              _isOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
              size: 24,
              color: _isOpen ? Colors.black : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}