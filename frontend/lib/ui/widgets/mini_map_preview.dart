import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MiniMapPreview extends StatefulWidget {
  final double lat;
  final double lng;

  const MiniMapPreview({
    super.key,
    required this.lat,
    required this.lng,
  });

  @override
  State<MiniMapPreview> createState() => _MiniMapPreviewState();
}

class _MiniMapPreviewState extends State<MiniMapPreview> {
  final MapController _mapController = MapController();

  final double _minZoom = 3.0;
  final double _maxZoom = 18.0;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _animatedZoom(double zoomChange) {
    final center = _mapController.camera.center;
    final currentZoom = _mapController.camera.zoom;
    final newZoom = (currentZoom + zoomChange).clamp(_minZoom, _maxZoom);
    _mapController.move(center, newZoom);
  }

  // Funzione per tornare al punto rosso
  void _recenter() {
    _mapController.move(LatLng(widget.lat, widget.lng), 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(widget.lat, widget.lng),
            initialZoom: 15.0,

            // --- QUI LA MODIFICA PRINCIPALE ---
            interactionOptions: const InteractionOptions(
              // Abilita spostamento e zoom, ma blocca la rotazione (opzionale)
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.safeguard.frontend',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(widget.lat, widget.lng),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.red,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black45)],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Pulsanti
        Positioned(
          bottom: 10,
          right: 10,
          child: Column(
            children: [
              // 1. Bottone Ricentra (Nuovo!)
              // Utile se l'utente si sposta troppo e perde il marker
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.center_focus_strong, color: Colors.blue),
                  onPressed: _recenter,
                  tooltip: "Ricentra posizione",
                ),
              ),
              const SizedBox(height: 15), // Un po' di spazio extra

              // 2. Zoom In
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.black87),
                  onPressed: () => _animatedZoom(1.0),
                ),
              ),

              const SizedBox(height: 8),

              // 3. Zoom Out
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                ),
                child: IconButton(
                  icon: const Icon(Icons.remove, color: Colors.black87),
                  onPressed: () => _animatedZoom(-1.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}