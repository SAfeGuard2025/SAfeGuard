import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:frontend/ui/widgets/emergency_card.dart';
import '../../widgets/emergency_detail_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EmergencyGridPage extends StatefulWidget {
  const EmergencyGridPage({super.key});

  @override
  State<EmergencyGridPage> createState() => _EmergencyGridPageState();
}

class _EmergencyGridPageState extends State<EmergencyGridPage> {
  @override
  void initState() {
    super.initState();
    // Carica le segnalazioni all'avvio della schermata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).loadReports();
    });
  }

  //FUNZIONE PER GENERARE IL PDF DEL LOG COMPLETO
  Future<void> _generateFullLogPdf(
    BuildContext context,
    List<Map<String, dynamic>> emergencies,
  ) async {
    final pdf = pw.Document();
    final logoImage = await imageFromAssetBundle('assets/logo.png');
    final DateTime now = DateTime.now();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // Intestazione di ogni pagina
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SafeGuard Log Interventi',
                  style: pw.TextStyle(
                    color: PdfColors.grey,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Generato il: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}',
                ),
              ],
            ),
          );
        },
        // Contenuto principale
        build: (pw.Context context) {
          return [
            pw.Center(child: pw.Image(logoImage, height: 60, width: 60)),
            pw.SizedBox(height: 20),
            pw.Header(level: 0, child: pw.Text("REGISTRO EMERGENZE ATTIVE")),
            pw.SizedBox(height: 20),

            // Tabella Dati
            pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.orange),
              cellAlignment: pw.Alignment.centerLeft,
              headers: <String>[
                'ID',
                'Tipo',
                'Descrizione',
                'Data/Ora',
                'Gravità',
              ],
              data: emergencies.map((item) {
                // Formattazione Data
                final dateRaw = item['timestamp']?.toString();
                String dateFmt = "N/D";
                if (dateRaw != null) {
                  try {
                    final dt = DateTime.parse(dateRaw);
                    dateFmt = "${dt.day}/${dt.month} ${dt.hour}:${dt.minute}";
                  } catch (_) {}
                }

                // Costruzione riga tabella
                return [
                  item['id']?.toString().substring(0, 5) ?? 'N/D', // ID breve
                  item['type']?.toString().toUpperCase() ?? 'GENERICO',
                  item['description']?.toString() ?? '-',
                  dateFmt,
                  item['severity']?.toString() ?? '1',
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "Totale Emergenze: ${emergencies.length}",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ];
        },
      ),
    );
    // Apre l'anteprima di stampa/salvataggio
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    //Recupero dati utente per i filtri
    final authProvider = context.watch<AuthProvider>();
    final isRescuer = authProvider.isRescuer;
    // ID utente corrente
    final currentUserId = authProvider.currentUser?.id?.toString();

    final reportProvider = context.watch<ReportProvider>();

    //LOGICA DI FILTRAGGIO AGGIORNATA
    final activeEmergencies = reportProvider.emergencies.where((e) {
      final String type = e['type']?.toString() ?? '';

      //Nascondi sempre "SAFE" (Stato "Sto bene")
      if (type == 'SAFE') return false;

      //Se sei un soccorritore, vedi tutto il resto
      if (isRescuer) return true;

      //Se sei un CITTADINO:
      // Recupera la gravità
      final int severity = (e['severity'] is int) ? e['severity'] : 1;

      final bool isPrivateSOS = type.contains('SOS') || severity >= 5;

      if (isPrivateSOS) {
        // Recupera l'ID del proprietario del report
        final String? ownerId =
            e['user_id']?.toString() ?? e['rescuer_id']?.toString();

        return ownerId == currentUserId;
      }

      // Mostra le altre emergenze (Arancioni/Pubbliche)
      return true;
    }).toList();

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
          //PULSANTE DOWNLOAD LOG (Visibile solo ai Soccorritori)
          if (isRescuer)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: "Scarica Log Completo (PDF)",
              onPressed: () {
                if (activeEmergencies.isNotEmpty) {
                  // Passiamo la lista FILTRATA (senza SAFE)
                  _generateFullLogPdf(context, activeEmergencies);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nessuna emergenza da scaricare."),
                    ),
                  );
                }
              },
            ),

          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => reportProvider.loadReports(),
          ),
        ],
      ),

      body: Builder(
        builder: (context) {
          // Stato di Caricamento
          if (reportProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (activeEmergencies.isEmpty) {
            return const Center(
              child: Text(
                "Nessuna segnalazione presente",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          // 1. Costruzione della griglia delle emergenze
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: activeEmergencies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final item = activeEmergencies[index];

                return EmergencyCard(
                  data: item,
                  // Gestione chiusura emergenza
                  onClose: () async {
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
                  // Apertura dettagli (Solo per soccorritori)
                  onTap: () {
                    // Dettagli visibili solo ai soccorritori
                    if (isRescuer) {
                      showDialog(
                        context: context,
                        builder: (ctx) => EmergencyDetailDialog(item: item),
                      );
                    }
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
