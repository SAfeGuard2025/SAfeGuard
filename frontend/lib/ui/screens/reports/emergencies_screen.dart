import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/emergency_card.dart';

import '../../widgets/mini_map_preview.dart';

// Schermata principale per la visualizzazione delle emergenze attive
class EmergencyGridPage extends StatefulWidget {
  const EmergencyGridPage({super.key});

  @override
  State<EmergencyGridPage> createState() => _EmergencyGridPageState();
}

class _EmergencyGridPageState extends State<EmergencyGridPage> {
  @override
  void initState() {
    super.initState();
    //Carica i dati all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      backgroundColor: !isRescuer
          ? ColorPalette.backgroundDarkBlue
          : ColorPalette.primaryOrange,

      appBar: AppBar(
        title: const Text(
          "Emergenze Attive",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Tasto refresh manuale
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            // Chiama loadReports per ricaricare i dati dal DB.
            onPressed: () => reportProvider.loadReports(),
          ),
        ],
      ),

      // Contenuto Principale
      body: Builder(
        builder: (context) {
          // 1. Stato di Caricamento
          if (reportProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // 2. Lista vuota
          if (reportProvider.emergencies.isEmpty) {
            return const Center(
              child: Text(
                "Nessuna segnalazione presente",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          // 3. Griglia delle segnalazioni attive
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: reportProvider.emergencies.length,
              // Definisce la struttura della griglia (2 colonne fisse).
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8, // Regola l'altezza delle card
              ),
              itemBuilder: (context, index) {
                final item = reportProvider.emergencies[index];
                IconData icon;

                // Costruisce l'icona in base alla tipologia d'emergenza
                switch(item['type'].toString().toUpperCase()){
                  case 'INCENDIO':
                    icon = Icons.local_fire_department;
                    break;
                  case 'TSUNAMI':
                    icon = Icons.water;
                    break;
                  case 'ALLUVIONE':
                    icon = Icons.flood;
                    break;
                  case 'MALESSERE':
                    icon = Icons.medical_services;
                    break;
                  case 'BOMBA':
                    icon = Icons.warning;
                    break;
                  default:
                    icon = Icons.warning_amber_rounded;
                }

                // Costruisce la singola Card per l'emergenza.
                return EmergencyCard(
                  data: item, // Passa i dati specifici dell'emergenza.
                  onClose: () async {
                    // Logica di chiusura chiamata dal bottone
                    bool confirm =
                        await showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Conferma"),
                            content: const Text(
                              "Vuoi chiudere questa segnalazione?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text("Si"),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirm) {
                      await reportProvider.resolveReport(item['id']);
                    }
                  },
                  // Costruisce la card per la visualizzazione in dettaglio dell'emergenza
                  // ... dentro itemBuilder ...
                  onTap: () async {
                    // 1. Estrai le coordinate in modo sicuro
                    // Convertiamo in double perché dal JSON/DB potrebbero arrivare come numeri generici
                    final double? eLat = (item['lat'] as num?)?.toDouble();
                    final double? eLng = (item['lng'] as num?)?.toDouble();

                    showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 10,
                          backgroundColor: ColorPalette.cardDarkOrange,
                          child: ConstrainedBox( // Impedisce che il dialog diventi troppo grande
                            constraints: const BoxConstraints(maxHeight: 500),
                            child: SingleChildScrollView( // Evita overflow su schermi piccoli
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
                                  children: [
                                    Icon(
                                      icon,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item['type'].toString().toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),

                                    Text(
                                      item['description'].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 20),

                                    // --- ZONA MAPPA CORRETTA ---
                                    if (eLat != null && eLng != null)
                                      SizedBox(
                                        height: 180, // ALTEZZA FISSA: Risolve errore "Infinity"
                                        width: double.infinity,
                                        child: ClipRRect( // DECORAZIONE: Arrotonda gli angoli
                                          borderRadius: BorderRadius.circular(20.0),
                                          // Qui usiamo il widget creato sopra, passando le coordinate dell'item
                                          child: MiniMapPreview(
                                              lat: eLat,
                                              lng: eLng
                                          ),
                                        ),
                                      )
                                    else
                                    // Fallback se non ci sono coordinate
                                      Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Posizione non disponibile",
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
