import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/realtime_map.dart';

// La classe rappresenta la pagina specifica per la visualizzazione della mappa
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    // Restituisce direttamente la mappa a tutto schermo
    return const RealtimeMap();
  }
}