import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata Gestione Allergie
// Consente all'utente di visualizzare, aggiungere e rimuovere le proprie allergie.
class AllergieScreen extends StatefulWidget {
  const AllergieScreen({super.key});

  @override
  State<AllergieScreen> createState() => _AllergieScreenState();
}

class _AllergieScreenState extends State<AllergieScreen> {
  // Controller per gestire l'input di testo nel dialog di aggiunta
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dopo che il frame è stato costruito, avvia il caricamento delle allergie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalProvider>(context, listen: false).loadAllergies();
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
    const Color addBtnColor = ColorPalette.accentControlBlue;

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
            const SizedBox(height: 30),

            // Contenitore principale della lista
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

                  // Consumer: Ascolta i cambiamenti nel MedicalProvider
                  child: Consumer<MedicalProvider>(
                    builder: (context, provider, child) {
                      // Stato di caricamento
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // Lista vuota
                      if (provider.allergie.isEmpty) {
                        return const Center(
                          child: Text(
                            "Nessuna allergia",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      // Lista delle allergie
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10.0,
                        ),
                        itemCount: provider.allergie.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withValues(alpha: 0.1),
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          return _buildItem(
                            text: provider.allergie[index].name,
                            onEdit: () {
                              // Modifica disabilitata
                              _openDialog(isEdit: false);
                            },
                            onDelete: () async {
                              // Chiama il provider per rimuovere l'elemento
                              await provider.removeAllergia(index);
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

            // Bottone "Aggiungi un'allergia"
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 30.0,
              ),
              child: InkWell(
                onTap: () =>
                    _openDialog(isEdit: false), // Apre il dialog per l'aggiunta
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                    color: addBtnColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Aggiungi un’allergia",
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

  // Dialog per l'aggiunta di un allergia
  void _openDialog({required bool isEdit}) {
    // Pulisce il campo di testo prima di aprire il dialog
    _textController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorPalette.backgroundDarkBlue,
          title: const Text(
            "Nuova allergia",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Inserisci nome...",
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
                  // Chiama il provider per aggiungere la nuova allergia
                  final success = await Provider.of<MedicalProvider>(
                    context,
                    listen: false,
                  ).addAllergia(_textController.text);

                  // Se l'operazione ha successo e il contesto è ancora valido, chiude il dialog
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
