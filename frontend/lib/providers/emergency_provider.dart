import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:frontend/services/user_api_service.dart';

// Provider di Stato: EmergencyProvider
class EmergencyProvider extends ChangeNotifier {
  bool _isSendingSos = false;
  final UserApiService _apiService = UserApiService();

  bool get isSendingSos => _isSendingSos;

  // Funzione che esegue la chiamata API al backend
  Future<void> sendSos({
    required double latitude,
    required double longitude,
    required String authToken,
    String? type,
    String? description,
  }) async {
    _isSendingSos = true;
    notifyListeners();

    try {
      // Chiamata all'endpoint protetto nel backend
      await _apiService.callSOSApi(
        latitude: latitude,
        longitude: longitude,
        authToken: authToken,
        type: type,
        description: description,
      );

    } catch (e) {
      // Rilascia l'errore al widget per la gestione del messaggio
      rethrow;
    } finally {
      _isSendingSos = false;
      notifyListeners();
    }
  }
}