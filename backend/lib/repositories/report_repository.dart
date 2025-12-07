import 'package:firedart/firedart.dart';

class ReportRepository {
  // Collezione corretta su Firestore
  CollectionReference get _collection => Firestore.instance.collection('active_emergencies');

  // 1. Salva il report su DB
  // Il repository deve solo ricevere i dati (Map) e scriverli.
  // NON deve inviare notifiche (compito del Service).
  Future<void> createReport(Map<String, dynamic> reportData) async {
    // Genera un ID basato sul tempo
    final String customId = DateTime.now().millisecondsSinceEpoch.toString();

    // Scrive su Firestore
    await _collection.document(customId).set(reportData);
  }

  // 2. Legge tutti i report
  Future<List<Map<String, dynamic>>> getAllReports() async {
    final snapshot = await _collection.get();

    return snapshot.map((doc) {
      final data = doc.map;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // 3. Cancella un report
  Future<void> deleteReport(String id) async {
    await _collection.document(id).delete();
  }
}