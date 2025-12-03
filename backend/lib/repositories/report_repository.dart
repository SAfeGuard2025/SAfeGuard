import 'package:firedart/firedart.dart';

class ReportRepository {
  // Collezione corretta
  CollectionReference get _collection => Firestore.instance.collection('active_emergencies');

  // Salva il report su DB usando il TIMESTAMP come ID
  Future<void> createReport(Map<String, dynamic> reportData) async {

    final String customId = DateTime.now().millisecondsSinceEpoch.toString();


    await _collection.document(customId).set(reportData);
  }

  // Legge tutti i report
  Future<List<Map<String, dynamic>>> getAllReports() async {
    final snapshot = await _collection.get();

    return snapshot.map((doc) {
      final data = doc.map;
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}