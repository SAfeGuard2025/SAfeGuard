import 'package:firedart/firedart.dart';

class ReportRepository {
  // 1. Collezione per i report ATTIVI (Dati grezzi visualizzati sulla mappa dell'App)
  CollectionReference get _activeCollection =>
      Firestore.instance.collection('active_emergencies');

  // 2. Collezione per i report ANALIZZATI (Registro storico con i dati dell'AI)
  CollectionReference get _analyzedCollection =>
      Firestore.instance.collection('analyzed_reports');

  // --- GESTIONE EMERGENZE ATTIVE ---

  // Crea il report iniziale (senza dati AI)
  Future<void> createReport(
    Map<String, dynamic> reportData,
    String customId,
  ) async {
    await _activeCollection.document(customId).set(reportData);
  }

  // Legge tutti i report attivi
  Future<List<Map<String, dynamic>>> getAllReports() async {
    final snapshot = await _activeCollection.get();
    return snapshot.map((doc) {
      final data = doc.map;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Cancella un report attivo (quando viene risolto o chiuso)
  Future<void> deleteReport(String id) async {
    await _activeCollection.document(id).delete();
  }

  // --- GESTIONE REPORT ANALIZZATI ---

  // Salva il report COMPLETO (Dati Originali + Dati AI) nella collezione separata
  Future<void> createAnalyzedReport(Map<String, dynamic> fullData) async {
    // Usiamo lo stesso ID per correlazione, ma è un documento fisicamente diverso
    final String docId = fullData['id'].toString();
    try {
      await _analyzedCollection.document(docId).set(fullData);
      print("💾 Salvato con successo in analyzed_reports: $docId");
    } catch (e) {
      print("❌ Errore durante il salvataggio in analyzed_reports: $e");
    }
  }
}
