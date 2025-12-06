import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Widget riutilizzabile per visualizzare una singola segnalazione/emergenza
class EmergencyCard extends StatelessWidget {
  final Map<String, dynamic> data; // Dati completi dell'emergenza
  final VoidCallback? onTap;       // Callback per gestire il tap sulla card
  final VoidCallback? onClose;     // Callback per l'azione di chiusura (visibile solo ai soccorritori)

  const EmergencyCard({
    super.key,
    required this.data,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    // Colori di sfondo
    final bgColor = !isRescuer
        ? ColorPalette.backgroundDeepBlue
        : ColorPalette.amberOrange;

    // Estrazione dati sicura
    final String type = data['type']?.toString() ?? 'GENERICO';
    final String description = data['description']?.toString() ?? 'Nessuna descrizione';

    // Formattazione orario (solo se presente)
    String timeString = '';
    if (data['timestamp'] != null) {
      try {
        DateTime dt = DateTime.parse(data['timestamp'].toString());
        // Formato HH:mm
        timeString = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuisce lo spazio
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Riga superiore: Icona di allerta e Orario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 32, color: Colors.white),
                // Mostra l'orario solo se la stringa è stata formattata correttamente.
                if (timeString.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      timeString,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            // Corpo: Titolo e Descrizione
            Center(
              child: Column(
                children: [
                  // Tipo di emergenza
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
                  // Descrizione (mostrata solo se non vuota)
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

            // Bottone Chiudi Intervento
            // Visibile solo se: L'utente è un Soccorritore
            if (isRescuer && onClose != null)
              SizedBox(
                width: double.infinity,
                height: 35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: ColorPalette.cardDarkOrange, // Testo arancione scuro
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onClose, // Esegue la funzione di chiusura fornita dal padre.
                  child: const Text(
                    "CHIUDI INTERVENTO",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            else
            // Spazio vuoto per mantenere le dimensioni uniformi se non c'è bottone
              const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}