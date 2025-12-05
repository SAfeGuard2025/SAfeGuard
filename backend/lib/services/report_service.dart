import '../repositories/report_repository.dart';

class ReportService {
  final ReportRepository _repository = ReportRepository();

  Future<void> createReport({
    required int rescuerId,
    required String type,
    String? description,
    double? lat,
    double? lng,
  }) async {
    // Qui prepariamo l'oggetto finale da salvare
    final reportData = {
      'rescuer_id': rescuerId,
      'type': type,
      'description': description ?? '',
      'status': 'active',
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _repository.createReport(reportData);
  }

  Future<List<Map<String, dynamic>>> getReports() async {
    return await _repository.getAllReports();
  }
}