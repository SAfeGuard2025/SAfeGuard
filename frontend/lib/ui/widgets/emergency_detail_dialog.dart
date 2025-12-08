import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../style/color_palette.dart';
import 'mini_map_preview.dart';

class EmergencyDetailDialog extends StatefulWidget {
  final Map<String, dynamic> item;

  const EmergencyDetailDialog({super.key, required this.item});

  @override
  State<EmergencyDetailDialog> createState() => _EmergencyDetailDialogState();
}

class _EmergencyDetailDialogState extends State<EmergencyDetailDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Ricerca dei dati del cittadino
  Future<DocumentSnapshot?> _fetchCitizenProfile(String? userId) async {
    if (userId == null || userId.isEmpty) return null;

    try {
      var doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) return doc;
    } catch (e) {
      debugPrint("Errore fetch cittadino: $e");
    }
    return null;
  }

  // Costruisce l'icona
  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'INCENDIO': return Icons.local_fire_department;
      case 'TSUNAMI': return Icons.water;
      case 'ALLUVIONE': return Icons.flood;
      case 'MALESSERE': return Icons.medical_services;
      case 'BOMBA': return Icons.warning;
      default: return Icons.warning_amber_rounded;
    }
  }

  // Calcola l'età in base alla data di nascita
  String _calculateAge(dynamic birthDateData) {
    if (birthDateData == null) return "N/D";
    DateTime date = DateTime.now();
    if (birthDateData is Timestamp) date = birthDateData.toDate();
    else if (birthDateData is String) {
      final parsed = DateTime.tryParse(birthDateData);
      if (parsed != null) date = parsed;
    }
    final DateTime today = DateTime.now();
    int age = today.year - date.year;
    if (today.month < date.month || (today.month == date.month && today.day < date.day)) age--;
    return "$age anni";
  }

  String _formatMedicalNotes(dynamic data) {
    if (data == null) return "Nessuna patologia segnalata";
    if (data is List) return data.isEmpty ? "Nessuna patologia segnalata" : data.join(", ");
    String text = data.toString().replaceAll('[', '').replaceAll(']', '').trim();
    return text.isEmpty ? "Nessuna patologia segnalata" : text;
  }

  // Costruzione del dialog
  @override
  Widget build(BuildContext context) {
    final double? eLat = (widget.item['lat'] as num?)?.toDouble();
    final double? eLng = (widget.item['lng'] as num?)?.toDouble();
    final IconData icon = _getIconForType(widget.item['type'].toString());

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 10,
      backgroundColor: ColorPalette.cardDarkOrange,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildEmergencyPage(eLat, eLng, icon),
                    _buildCitizenPage(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Pallini
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 12 : 8,
                    height: _currentPage == index ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.white : Colors.white38,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              Text(
                _currentPage == 0 ? "Scorri per info cittadino >" : "< Torna ai dettagli",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Scheda dell'emergenza
  Widget _buildEmergencyPage(double? lat, double? lng, IconData icon) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                const SizedBox(width: 15),
                Flexible(
                  child: Text(
                    widget.item['type'].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.item['description']?.toString() ?? 'Nessuna descrizione',
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (lat != null && lng != null)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: MiniMapPreview(lat: lat, lng: lng),
                ),
              )
            else
              Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: const Text("Posizione non disponibile", style: TextStyle(color: Colors.white70)),
              ),
          ],
        ),
      ),
    );
  }

  // 2. Scheda del cittadino
  Widget _buildCitizenPage() {
    return FutureBuilder<DocumentSnapshot?>(
      future: _fetchCitizenProfile(widget.item['user_id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        // Caso soccorritore
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.security, size: 40, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Segnalazione Operatore",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Questa segnalazione è stata creata da un Soccorritore o da un operatore del sistema.",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Non sono disponibili dati anagrafici pubblici per questo utente.",
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                ],
              ),
            ),
          );
        }

        // Caso cittadino
        final userData = snapshot.data!.data() as Map<String, dynamic>;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Dettagli Cittadino", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Nome:", "${userData['nome'] ?? userData['name'] ?? 'N/D'}"),
                      _buildInfoRow("Cognome:", "${userData['cognome'] ?? userData['surname'] ?? 'N/D'}"),
                      _buildInfoRow("Telefono:", "${userData['telefono'] ?? userData['phone'] ?? 'N/D'}"),
                      if (userData['dataDiNascita'] != null)
                        _buildInfoRow("Età:", _calculateAge(userData['dataDiNascita'])),

                      const Divider(color: Colors.white24, height: 20),
                      const Text("Note Mediche / Allergie:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 5),
                      Text(
                        _formatMedicalNotes(userData['medical_notes'] ?? userData['allergie']),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

              ],
            ),
          ),
        );
      },
    );
  }

  // Costruisce le righe nel dialog
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 15))),
        ],
      ),
    );
  }
}