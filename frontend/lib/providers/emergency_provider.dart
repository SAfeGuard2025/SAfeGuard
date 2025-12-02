import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

// Provider di Stato: EmergencyProvider
// Gestisce lo stato e la logica relativi all'attivazione delle emergenze
class EmergencyProvider extends ChangeNotifier {
  bool _isSendingSos = false;

  bool get isSendingSos => _isSendingSos;

  // Riferimento alla collezione "active_emergencies" su database
  final CollectionReference _firestore = FirebaseFirestore.instance.collection(
    'active_emergencies',
  );

  // Invia un segnale SOS immediato (Progressive SOS)
  Future<bool> sendInstantSos({
    required String userId,
    required String? email,
    required String? phone,
    String type = "Generico",
  }) async {
    // 0. Controllo preliminare Permessi e GPS (Richiesto per Sicurezza)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Il GPS è disattivato. Attivalo per inviare l'SOS.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception("Permessi GPS mancanti. Abilitali per inviare l'SOS.");
    }

    try {
      // 1. Imposta lo stato su "invio in corso"
      _isSendingSos = true;
      notifyListeners();

      // 2. FAST PATH: Ottieni l'ultima posizione nota (istantaneo)
      // Non aspettiamo il fix preciso qui, usiamo quello che abbiamo in cache
      Position? position = await Geolocator.getLastKnownPosition();

      double lat = position?.latitude ?? 0.0;
      double lng = position?.longitude ?? 0.0;

      // 3. Scrivi SUBITO sul database (Stage 1)
      final Map<String, dynamic> emergencyData = {
        "id": userId,
        "email": email ?? "N/A",
        "phone": phone ?? "N/A",
        "type": type,
        "lat": lat,
        "lng": lng,
        "accuracy": "approximate", // Flag per indicare che è una stima iniziale
        "timestamp": FieldValue.serverTimestamp(),
        "status": "active",
      };

      await _firestore.doc(userId).set(emergencyData);

      // 4. Avvia l'aggiornamento preciso in background (Stage 2)
      // NON usiamo 'await' qui per non bloccare la UI. Lasciamo che giri in background.
      _updateWithPreciseLocation(userId);

      return true; // Ritorna SUBITO true alla UI! 🚀
    } catch (e) {
      _isSendingSos = false;
      notifyListeners();
      return false;
    }
  }

  // Metodo background per raffinare la posizione
  Future<void> _updateWithPreciseLocation(String userId) async {
    try {
      // Richiede tempo (1-5 secondi)
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Aggiorna il documento esistente con la posizione precisa
      await _firestore.doc(userId).update({
        "lat": position.latitude,
        "lng": position.longitude,
        "accuracy": "precise",
      });
    } catch (e) {
      debugPrint("Errore aggiornamento posizione precisa SOS: $e");
      // Anche se fallisce, l'SOS è stato comunque inviato con la posizione approssimativa
    }
  }

  // Interrompe l'SOS attivo per un determinato utente
  Future<void> stopSos(String userId) async {
    await _firestore.doc(userId).delete();
    _isSendingSos = false;
    notifyListeners();
  }
}
