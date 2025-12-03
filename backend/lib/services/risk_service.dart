import 'package:firedart/firedart.dart';
import 'package:data_models/risk_hotspot.dart';

class RiskService {
  // Nome della collezione dove sono salvati gli hotspot
  static const String _hotspotsCollection = 'risk_areas';

  // Recupera la lista degli hotspot dal database Firestore.
  Future<List<RiskHotspot>> getHotspots() async {
    try {
      final snapshot = await Firestore.instance
          .collection(_hotspotsCollection)
          .get();

      return snapshot.map((doc) {
        final data = doc.map;
        data['id'] = int.tryParse(doc.id) ?? -1;

        // Usa il factory constructor per creare l'oggetto
        return RiskHotspot.fromJson(data);
      }).toList();
    } catch (e) {
      print('SERVICE: Errore nel recupero Hotspots: $e');
      throw Exception('Impossibile recuperare i dati.');
    }
  }
}
