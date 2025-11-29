import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata Gestione Medicinali
// Consente all'utente di visualizzare, aggiungere e rimuovere i farmaci che sta assumendo.
class MedicinaliScreen extends StatefulWidget {
  const MedicinaliScreen({super.key});
  @override
  State<MedicinaliScreen> createState() => _MedicinaliScreenState();
}

class _MedicinaliScreenState extends State<MedicinaliScreen> {
  // Controller per gestire l'input di testo nel dialog di aggiunta
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carica i medicinali dal MedicalProvider all'avvio della schermata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalProvider>(context, listen: false).loadMedicines();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = ColorPalette.backgroundMidBlue;
    const Color cardColor = ColorPalette.backgroundDarkBlue;
    const Color deleteColor = ColorPalette.deleteRed;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Header con bottone indietro
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Titolo e Icona
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: ColorPalette.accentMediumOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication_liquid,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Medicinali",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Lista dei Medicinali
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 5.0,
                  ),
                  // Consumer: ascolta i cambiamenti nella lista medicinali
                  child: Consumer<MedicalProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.medicinali.isEmpty) {
                        return const Center(
                          child: Text(
                            "Nessun farmaco inserito",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10.0,
                        ),
                        itemCount: provider.medicinali.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.white.withValues(alpha: .1)),
                        itemBuilder: (context, index) {
                          return _buildItem(
                            text: provider.medicinali[index].name,
                            onEdit: () {
                              // Modifica disabilitata
                              _openDialog(isEdit: false);
                            },
                            onDelete: () async {
                              // Chiama il provider per rimuovere l'elemento
                              await provider.removeMedicinale(index);
                            },
                            deleteColor: deleteColor,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Pulsante Aggiungi Farmaco
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 30.0,
              ),
              child: InkWell(
                onTap: () => _openDialog(isEdit: false),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                    color: ColorPalette.accentControlBlue,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Aggiungi un farmaco",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.greenAccent[400],
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget per il singolo elemento della lista
  Widget _buildItem({
    required String text,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required Color deleteColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              // Pulsante Elimina
              IconButton(
                icon: Icon(Icons.delete_outline, color: deleteColor, size: 28),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Dialog per l'aggiunta di un farmaco
  void _openDialog({required bool isEdit}) {
    // Pulisce il campo di testo prima di aprire il dialog
    _textController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorPalette.backgroundDarkBlue,
          title: const Text(
            "Nuovo farmaco",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Nome farmaco...",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orange),
              ),
            ),
          ),
          actions: [
            // Pulsante Annulla
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Annulla",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            // Pulsante Salva
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                if (_textController.text.isNotEmpty) {
                  // Chiama il provider per aggiungere il nuovo farmaco
                  final success = await Provider.of<MedicalProvider>(
                    context,
                    listen: false,
                  ).addMedicinale(_textController.text);

                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Salva", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
