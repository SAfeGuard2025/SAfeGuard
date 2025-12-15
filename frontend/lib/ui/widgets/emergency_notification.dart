import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/report_provider.dart'; // Importa ReportProvider
import 'package:provider/provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

class EmergencyNotification extends StatefulWidget {
  const EmergencyNotification({super.key});

  @override
  State<EmergencyNotification> createState() => _EmergencyNotification();
}

class _EmergencyNotification extends State<EmergencyNotification> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Questo avvia l'ascolto continuo
      Provider.of<ReportProvider>(
        context,
        listen: false,
      ).startRealtimeMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Controllo Stato Login
    final isLogged = context.watch<AuthProvider>().isLogged;
    if (!isLogged) return const SizedBox.shrink();

    // 2. Accesso ai dati del ReportProvider
    final reportProvider = context.watch<ReportProvider>();
    final nearest = reportProvider.nearestEmergency;

    // Se non ci sono emergenze vicine, nascondi il banner
    if (nearest == null) {
      return const SizedBox.shrink();
    }

    // 3. Estrazione Dati Dinamici
    // Usa il tipo come Titolo (es. INCENDIO)
    final String titolo =
        nearest['type']?.toString().toUpperCase() ?? "ALLERTA";

    // Usa la descrizione o la distanza calcolata come sottotitolo
    final String descrizioneDB = nearest['description']?.toString() ?? "";
    final String distanza = reportProvider.distanceString;

    // Combina descrizione e distanza per l'indirizzo/info
    final String indirizzoInfo = descrizioneDB.isNotEmpty
        ? "$descrizioneDB • $distanza"
        : distanza;

    // 4. Determinazione Colori (Logica esistente mantenuta)
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    Color notificationColor = isRescuer
        ? ColorPalette.electricBlue
        : ColorPalette.primaryBrightRed;

    const emergencyIcon =
        Icons.warning_amber_rounded; // Icona più appropriata per allerta

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: notificationColor,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Icona animata (opzionale: pulsazione)
            const Icon(emergencyIcon, color: Colors.white, size: 36.0),

            const SizedBox(width: 16.0),

            // Contenuto Testuale Aggiornato
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    titolo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w900, // Grassetto forte
                      letterSpacing: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    indirizzoInfo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
