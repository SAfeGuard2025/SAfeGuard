import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/widgets/realtime_map.dart';
import 'package:frontend/ui/style/color_palette.dart';

// La classe rappresenta la pagina specifica per la visualizzazione della mappa
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Dati grezzi scaricati dal DB
  List<Map<String, dynamic>> _allRawPoints = [];

  // Lista filtrata e ordinata da mostrare (Top 3)
  List<Map<String, dynamic>> _nearestPoints = [];

  bool _isLoadingList = true;
  String? _errorList;

  // Stream per la posizione GPS
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTracking();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initTracking() async {
    // PRELEVA IL PROVIDER PRIMA DI QUALSIASI AWAIT LUNGO
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 1. Controllo Permessi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS disabilitato");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Permessi GPS negati");
        }
      }

      // 2. Controllo Mounted prima di usare il Provider o setState dopo gli Await
      if (!mounted) return;

      // 3. Caricamento Dati in base al Ruolo
      final isRescuer = authProvider.isRescuer;
      if (isRescuer) {
        await _fetchEmergenciesFromDB();
      } else {
        await _fetchSafePointsFromDB();
      }

      // 4. Avvio Tracking Posizione
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      );

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: locationSettings,
          ).listen(
            (Position position) {
              _updateDistances(position);
            },
            onError: (e) {
              if (mounted) setState(() => _errorList = "Errore GPS: $e");
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorList = e.toString();
          _isLoadingList = false;
        });
      }
    }
  }

  //Carica Safe Points e Ospedali
  Future<void> _fetchSafePointsFromDB() async {
    try {
      final safePointsSnap = await FirebaseFirestore.instance
          .collection('safe_points')
          .get();
      final hospitalsSnap = await FirebaseFirestore.instance
          .collection('hospitals')
          .get();

      List<Map<String, dynamic>> loadedPoints = [];

      void extract(QuerySnapshot snap, String type) {
        for (var doc in snap.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final double? lat = (data['lat'] as num?)?.toDouble();
          final double? lng = (data['lng'] as num?)?.toDouble();
          final String name =
              data['name'] ??
              (type == 'hospital' ? 'Ospedale' : 'Punto Sicuro');

          if (lat != null && lng != null) {
            loadedPoints.add({
              'title': name,
              'subtitle': type == 'hospital'
                  ? "Pronto Soccorso"
                  : "Punto di Raccolta",
              'type': type, // 'hospital' o 'safe_point'
              'lat': lat,
              'lng': lng,
              'distance': 0.0,
            });
          }
        }
      }

      extract(safePointsSnap, 'safe_point');
      extract(hospitalsSnap, 'hospital');

      _allRawPoints = loadedPoints;
    } catch (e) {
      debugPrint("Errore fetch SafePoints: $e");
    }
  }

  //Carica Emergenze Attive
  Future<void> _fetchEmergenciesFromDB() async {
    try {
      final emergenciesSnap = await FirebaseFirestore.instance
          .collection('active_emergencies')
          .get();

      List<Map<String, dynamic>> loadedPoints = [];

      for (var doc in emergenciesSnap.docs) {
        final data = doc.data();
        final double? lat = (data['lat'] as num?)?.toDouble();
        final double? lng = (data['lng'] as num?)?.toDouble();
        final String type = data['type']?.toString() ?? "Emergenza";
        final String desc = data['description']?.toString() ?? "";

        // Escludiamo i report "SAFE" (Persone che stanno bene) dalla lista interventi
        if (type == 'SAFE') continue;

        if (lat != null && lng != null) {
          loadedPoints.add({
            'title': type.toUpperCase(),
            'subtitle': desc.isNotEmpty ? desc : "Nessuna descrizione",
            'type': 'emergency',
            'severity': data['severity'] ?? 1,
            'lat': lat,
            'lng': lng,
            'distance': 0.0,
          });
        }
      }
      _allRawPoints = loadedPoints;
    } catch (e) {
      debugPrint("Errore fetch Emergenze: $e");
    }
  }

  // Ricalcolo Distanze e Ordinamento
  void _updateDistances(Position userPos) {
    if (_allRawPoints.isEmpty) {
      if (mounted) setState(() => _isLoadingList = false);
      return;
    }

    List<Map<String, dynamic>> updatedList = List.from(_allRawPoints);

    for (var point in updatedList) {
      double dist = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        point['lat'],
        point['lng'],
      );
      point['distance'] = dist;
    }

    // Ordina dal più vicino
    updatedList.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    if (mounted) {
      setState(() {
        _nearestPoints = updatedList.take(20).toList();
        _isLoadingList = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    // Colori e Testi dinamici in base al ruolo
    final Color panelColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundDarkBlue;
    final Color cardColor = isRescuer
        ? ColorPalette.primaryOrange
        : ColorPalette.backgroundDarkBlue;
    final String listTitle = isRescuer
        ? "Interventi più vicini"
        : "Punti sicuri più vicini";
    final IconData headerIcon = isRescuer
        ? Icons.warning_amber_rounded
        : Icons.directions_walk;

    return Scaffold(
      backgroundColor: ColorPalette.backgroundDarkBlue,
      body: Stack(
        children: [
          // 1. Mappa a tutto schermo (livello inferiore)
          const Positioned.fill(child: RealtimeMap()),

          // 2. Pannello interattivo (livello superiore)
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.15,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),

                // ClipRRect forza i bordi curvi della sezione superiore
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      // Header della sezione superiore bloccato in alto
                      SliverAppBar(
                        pinned: true,
                        floating: false,
                        backgroundColor: panelColor,
                        automaticallyImplyLeading: false,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        toolbarHeight: 75,
                        flexibleSpace: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Maniglia grafica
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 5,
                                ),
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            // Intestazione con Icona e Titolo
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Icon(headerIcon, color: Colors.white),
                                  const SizedBox(width: 10),
                                  Text(
                                    listTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(color: Colors.white12, height: 1),
                          ],
                        ),
                      ),

                      // Gestione Contenuto (Loading / Errori / Lista)
                      if (_isLoadingList)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      else if (_errorList != null)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              "Errore: $_errorList",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        )
                      else if (_nearestPoints.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              isRescuer
                                  ? "Nessuna emergenza attiva."
                                  : "Nessun punto sicuro vicino.",
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ),
                        )
                      else
                        // Lista dei risultati
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = _nearestPoints[index];

                            // Formattazione Distanza
                            final double d = item['distance'];
                            final String distStr = d < 1000
                                ? "${d.toStringAsFixed(0)} m"
                                : "${(d / 1000).toStringAsFixed(1)} km";

                            // Icona dinamica
                            IconData itemIcon;
                            Color iconBgColor;
                            Color iconColor;

                            if (item['type'] == 'hospital') {
                              itemIcon = Icons.local_hospital;
                              iconBgColor = Colors.blue.withValues(alpha: 0.2);
                              iconColor = Colors.blueAccent;
                            } else if (item['type'] == 'safe_point') {
                              itemIcon = Icons.verified_user;
                              iconBgColor = Colors.green.withValues(alpha: 0.2);
                              iconColor = Colors.greenAccent;
                            } else {
                              // Caso Emergenza (Soccorritore)
                              itemIcon = Icons.report_problem;
                              iconBgColor = Colors.red.withValues(alpha: 0.2);
                              iconColor = Colors.redAccent;
                            }

                            return Card(
                              color: cardColor,
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: iconBgColor,
                                  child: Icon(itemIcon, color: iconColor),
                                ),
                                title: Text(
                                  item['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  item['subtitle'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    distStr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }, childCount: _nearestPoints.length),
                        ),

                      // Spazio extra in fondo per lo scroll
                      const SliverToBoxAdapter(child: SizedBox(height: 30)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
