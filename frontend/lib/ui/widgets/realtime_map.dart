import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/risk_provider.dart';
// Import necessario per accedere all'utente corrente
import 'package:frontend/providers/auth_provider.dart';

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
  final CollectionReference _safePointsRef = FirebaseFirestore.instance.collection('safe_points');
  final CollectionReference _hospitalsRef = FirebaseFirestore.instance.collection('hospitals');
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

    // Carica i dati di rischio all'avvio della mappa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RiskProvider>(context, listen: false).loadHotspots();
    });
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
            if (!widget.isSelectionMode) {
              _mapController.move(_center, 15.0);
            }
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

  // Helper per costruire il pallino colorato (sostituisce il pin)
  Widget _buildDotMarker(Color color, {bool pulse = false}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: pulse ? 15 : 6,
            spreadRadius: pulse ? 5 : 1,
          )
        ],
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ottieni gli hotspot dal provider
    final riskHotspots = context.watch<RiskProvider>().hotspots;

    //Ottieni dati utente corrente per il filtro
    final authProvider = context.watch<AuthProvider>();
    final isRescuer = authProvider.isRescuer;
    final currentUserId = authProvider.currentUser?.id?.toString();

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

            //NUOVO LAYER HOTSPOTS AI
            CircleLayer(
              circles: riskHotspots.map((hotspot) {
                return CircleMarker(
                  point: LatLng(hotspot.centerLat, hotspot.centerLng),
                  color: Colors.red.withValues(alpha: 0.3),
                  borderColor: Colors.red,
                  borderStrokeWidth: 2,
                  useRadiusInMeter: true,
                  radius: hotspot.radiusKm * 1000, //Converte km in metri
                );
              }).toList(),
            ),

            //STREAM BUILDER PER I PUNTI DI RACCOLTA
            StreamBuilder<QuerySnapshot>(
              stream: _safePointsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return const MarkerLayer(markers: []);
                }
                final markers = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double lat = data['lat'];
                  final double lng = data['lng'];
                  final String name = data['name'] ?? 'Punto Sicuro';

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("🟢 Punto di Raccolta: $name"),
                            backgroundColor: Colors.green[700],
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              size: 28,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
                return MarkerLayer(markers: markers);
              },
            ),

            // 2. LAYER OSPEDALI (HOSPITALS) - BLU
            StreamBuilder<QuerySnapshot>(
              stream: _hospitalsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const MarkerLayer(markers: []);

                final markers = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final double lat = data['lat'];
                  final double lng = data['lng'];
                  final String name = data['name'] ?? 'Ospedale';

                  return Marker(
                    point: LatLng(lat, lng),
                    width: 50, // Un po' più grandi per visibilità
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("🏥 Pronto Soccorso: $name"),
                            backgroundColor: Colors.blue[800],
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              size: 26,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList();
                return MarkerLayer(markers: markers);
              },
            ),

            // 2. StreamBuilder: Ascolta il database in tempo reale
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const MarkerLayer(markers: []);

                // Filtriamo e mappiamo i documenti
                final List<Marker> markers = [];

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;

                  final double lat = (data['lat'] is num) ? (data['lat'] as num).toDouble() : 0.0;
                  final double lng = (data['lng'] is num) ? (data['lng'] as num).toDouble() : 0.0;
                  final String type = data['type']?.toString() ?? 'Generico';
                  final int severity = (data['severity'] is int) ? data['severity'] : 1;

                  // Recupero ID proprietario (Supporta sia SOS che Report)
                  final String? ownerId = data['user_id']?.toString() ?? data['rescuer_id']?.toString();

                  // Recupero Timestamp per calcolare quanti secondi passano
                  DateTime? timestamp;
                  if (data['timestamp'] != null) {
                    timestamp = DateTime.tryParse(data['timestamp'].toString());
                  }

                  // LOGICA DI SCADENZA PER "STO BENE"
                  if (timestamp != null) {
                    final difference = DateTime.now().difference(timestamp).inSeconds;
                    // Se il dato è più vecchio di 60 secondi, lo nascondiamo.
                    if (difference > 60) {
                      continue;
                    }
                  }

                  // --- LOGICA DI VISUALIZZAZIONE E FILTRO ---
                  Widget markerWidget;

                  bool isCritical = false;

                  if (type == 'SAFE') {
                    markerWidget = _buildDotMarker(Colors.green, pulse: false);
                    isCritical = true;
                  } else if (type.contains('SOS') || severity >= 5) {
                    markerWidget = _buildDotMarker(Colors.red, pulse: true);
                    isCritical = true;
                  } else {
                    markerWidget = _buildDotMarker(Colors.orange, pulse: false);
                    isCritical = false;
                  }
                  // Se l'utente NON è un soccorritore:
                  if (!isRescuer) {
                    if (isCritical) {
                      // Controlla se è il proprietario
                      bool isMine = (currentUserId != null && ownerId == currentUserId);
                      if (!isMine) {
                        continue;
                      }
                    }
                  }

                  markers.add(
                    Marker(
                      point: LatLng(lat, lng),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("$type")),
                          );
                        },
                        child: markerWidget,
                      ),
                    ),
                  );
                }

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