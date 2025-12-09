import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Necessario per calcolare le distanze
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/realtime_map.dart';

class SafeCheckScreen extends StatefulWidget {
  final String title;

  const SafeCheckScreen({
    super.key,
    this.title = "ALLERTA DI SICUREZZA",
  });

  @override
  State<SafeCheckScreen> createState() => _SafeCheckScreenState();
}

class _SafeCheckScreenState extends State<SafeCheckScreen> {
  static const Color backgroundRed = ColorPalette.primaryBrightRed;
  static const Color safeGreen = ColorPalette.safeGreen;

  // Variabili di stato per i dati dinamici
  String _targetName = "Ricerca punto sicuro...";
  String _distanceText = "Calcolo distanza...";
  bool _isLoadingTarget = true;

  @override
  void initState() {
    super.initState();
    // Avvia il calcolo del punto più vicino appena si apre la pagina
    _findNearestSafePoint();
  }

  // Logica per trovare il punto più vicino (Safe Point o Ospedale)
  Future<void> _findNearestSafePoint() async {
    try {
      // 1. Ottieni la posizione attuale dell'utente
      Position userPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          )
      );

      // 2. Recupera i punti sicuri da Firebase
      // (Puoi cercare anche in 'hospitals' se preferisci)
      final safePointsSnapshot = await FirebaseFirestore.instance.collection('safe_points').get();
      final hospitalsSnapshot = await FirebaseFirestore.instance.collection('hospitals').get();

      // Uniamo le liste per trovare il più vicino in assoluto tra i due
      final allPoints = [
        ...safePointsSnapshot.docs,
        ...hospitalsSnapshot.docs
      ];

      if (allPoints.isEmpty) {
        if (mounted) {
          setState(() {
            _targetName = "Nessun punto sicuro trovato";
            _distanceText = "Resta in attesa di soccorsi";
            _isLoadingTarget = false;
          });
        }
        return;
      }

      double minDistance = double.infinity;
      String nearestName = "";

      // 3. Calcola il più vicino
      for (var doc in allPoints) {
        final data = doc.data();
        final double lat = data['lat'];
        final double lng = data['lng'];
        final String name = data['name'] ?? "Punto Sicuro";

        // Calcola distanza in metri
        double dist = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          lat,
          lng,
        );

        if (dist < minDistance) {
          minDistance = dist;
          nearestName = name;
        }
      }

      // 4. Formatta la distanza
      String formattedDistance;
      if (minDistance < 1000) {
        formattedDistance = "${minDistance.toStringAsFixed(0)} metri";
      } else {
        formattedDistance = "${(minDistance / 1000).toStringAsFixed(1)} km";
      }

      // 5. Aggiorna la UI
      if (mounted) {
        setState(() {
          _targetName = nearestName;
          _distanceText = "Distanza: $formattedDistance";
          _isLoadingTarget = false;
        });
      }

    } catch (e) {
      debugPrint("Errore calcolo safe point: $e");
      if (mounted) {
        setState(() {
          _targetName = "Posizione sconosciuta";
          _distanceText = "Impossibile calcolare il percorso";
          _isLoadingTarget = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Variabili per la responsività (stile confirm_emergency_screen.dart)
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width > 600;

    final double titleSize = isWideScreen ? 50 : 36;
    final double bodySize = isWideScreen ? 22 : 16;
    final double buttonTextSize = isWideScreen ? 24 : 18;

    return Scaffold(
      backgroundColor: backgroundRed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 10),

              // 1. Titolo Allerta
              Text(
                widget.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: titleSize,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 20),

              // 2. Mappa
              Expanded(
                child: _buildMapPlaceholder(isWideScreen),
              ),

              const SizedBox(height: 20),

              // 3. ISTRUZIONI DINAMICHE
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white30),
                ),
                child: Column(
                  children: [
                    Text(
                      "Dirigiti verso il punto sicuro più vicino:",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: bodySize * 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // NOME PUNTO (es. Ospedale San Leonardo)
                    _isLoadingTarget
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      _targetName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: bodySize * 1.3, // Molto grande
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    if (!_isLoadingTarget)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_walk, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            _distanceText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: bodySize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Pulsanti Azione
              Column(
                children: [
                  // Pulsante SOS (Rosso con bordo nero)
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE60000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          side: const BorderSide(color: Colors.black, width: 2.0),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        //TODO: Azione pulsante rosso
                      },
                      child: Text(
                        "HO BISOGNO DI AIUTO (SOS)",
                        style: TextStyle(
                          fontSize: buttonTextSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pulsante STO BENE
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: safeGreen,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () => _handleSafeCheck(context),
                      child: Text(
                        "STO BENE",
                        style: TextStyle(
                          fontSize: buttonTextSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget mappa
  Widget _buildMapPlaceholder(bool isWideScreen) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: ColorPalette.backgroundDarkBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: const RealtimeMap(), // <--- QUI C'È LA MAPPA VERA
      ),
    );
  }

  // Logica per gestire il "Sto Bene"
  Future<void> _handleSafeCheck(BuildContext context) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.currentUser;

      if (user == null) {
        Navigator.pop(context); // Chiudi se non loggato
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invio status in corso..."),
          duration: Duration(milliseconds: 800),
        ),
      );

      // Esempio di chiamata al provider (da implementare in EmergencyProvider)
      /* await context.read<EmergencyProvider>().sendSafeStatus(
            userId: user.id.toString(),
            location: "lat,long", // Opzionale: prendere posizione GPS attuale
          );
      */

      // Simulazione attesa rete
      await Future.delayed(const Duration(milliseconds: 500));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Grazie! Abbiamo registrato che sei al sicuro."),
          backgroundColor: safeGreen,
        ),
      );

      Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore di connessione: $e"),
          backgroundColor: backgroundRed,
        ),
      );
    }
  }
}