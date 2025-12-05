import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeMap extends StatefulWidget {
  // Parametri per la modalità selezione
  final bool isSelectionMode;
  final Function(LatLng)? onLocationPicked;

  const RealtimeMap({
    super.key,
    this.isSelectionMode = false, // Default false: comportamento normale
    this.onLocationPicked,
  });

  @override
  State<RealtimeMap> createState() => _RealtimeMapState();
}

class _RealtimeMapState extends State<RealtimeMap> {
  final MapController _mapController = MapController();

  // Riferimento alla collezione del database
  final CollectionReference _firestore = FirebaseFirestore.instance.collection(
    'active_emergencies',
  );

  // Coordinate di default (Salerno) usate finché il GPS non risponde
  LatLng _center = const LatLng(40.6824, 14.7681);
  final double _minZoom = 5.0;
  final double _maxZoom = 18.0;

  LatLng? _selectedPoint;

  // All'avvio, controlla i permessi GPS e inizializziamo la posizione
  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    if (serviceEnabled) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        try {
          Position position = await Geolocator.getCurrentPosition();
          if (mounted) {
            setState(() {
              _center = LatLng(position.latitude, position.longitude);
            });
            _mapController.move(_center, 15.0);
          }
        } catch (e) {
          debugPrint("Errore posizione: $e");
        }
      }
    }
  }

  //Gestione del tocco
  void _handleTap(TapPosition tapPosition, LatLng point) {
    if (widget.isSelectionMode) {
      setState(() {
        _selectedPoint = point;
      });
      if (widget.onLocationPicked != null) {
        widget.onLocationPicked!(point);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 13.0,
            minZoom: _minZoom,
            maxZoom: _maxZoom,
            //Abilitazione Tap
            onTap: _handleTap,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.safeguard.frontend',
            ),

            // 2. StreamBuilder: Ascolta il database in tempo reale
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const MarkerLayer(markers: []);
                final List<Marker> markers = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Marker(
                    point: LatLng(data['lat'] ?? 0, data['lng'] ?? 0),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                      },
                      child: const Icon(
                        Icons.location_on,
                        size: 50,
                        color: Colors.red,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                  );
                }).toList();
                return MarkerLayer(markers: markers);
              },
            ),

            // 3. Marker Posizione Utente (Pallino Blu)
            MarkerLayer(
              markers: [
                Marker(
                  point: _center,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(blurRadius: 10, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
                //Marker Verde Selezione
                if (_selectedPoint != null)
                  Marker(
                    point: _selectedPoint!,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.place,
                      size: 50,
                      color: Colors.green,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Pulsanti
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  try {
                    Position p = await Geolocator.getCurrentPosition();
                    final newC = LatLng(p.latitude, p.longitude);
                    setState(() => _center = newC);
                    _mapController.move(newC, 15.0);
                  } catch(e) { print(e); }
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 20),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  if (_mapController.camera.zoom < _maxZoom) {
                    _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  if (_mapController.camera.zoom > _minZoom) {
                    _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                  }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.remove, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}