import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/style/color_palette.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EmergencyCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const EmergencyCard({
    super.key,
    required this.data,
    this.onTap,
    this.onClose,
  });

  // Funzione che genera il pdf
  Future<void> _generatePdf(BuildContext context) async {
    final pdf = pw.Document();
    final logoImage = await imageFromAssetBundle('assets/logo.png');
    // Dati per la stampa
    final title = data['type']?.toString() ?? 'GENERICO';
    final desc = data['description']?.toString() ?? 'Nessuna descrizione';
    final time = data['timestamp']?.toString() ?? 'N/D';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Image(logoImage, height: 100, width: 100),
                ),
                pw.SizedBox(height: 20),
                pw.Text("TIPO: $title", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text("DESCRIZIONE: $desc"),
                pw.SizedBox(height: 10),
                pw.Text("DATA/ORA: $time"),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Text("Documento generato da SAfeGuard"),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final bgColor = !isRescuer
        ? ColorPalette.backgroundDeepBlue
        : ColorPalette.cardDarkOrange;
    final String type = data['type']?.toString() ?? 'GENERICO';
    IconData icon;
    final String description =
        data['description']?.toString() ?? 'Nessuna descrizione';

    switch(data['type'].toString().toUpperCase()){
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

    String timeString = '';
    if (data['timestamp'] != null) {
      try {
        DateTime dt = DateTime.parse(data['timestamp'].toString());
        timeString =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        timeString = '';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _generatePdf(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                            size: 16
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (timeString.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          timeString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            Center(
              child: Column(
                children: [
                  Text(
                    type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            if (isRescuer && onClose != null)
              SizedBox(
                width: double.infinity,
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                    ColorPalette.cardDarkOrange,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onClose,
                  child: const Text(
                    "CHIUDI INTERVENTO",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}