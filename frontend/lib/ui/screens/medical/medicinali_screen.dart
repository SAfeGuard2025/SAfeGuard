import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

class MedicinaliScreen extends StatefulWidget {
  const MedicinaliScreen({super.key});
  @override
  State<MedicinaliScreen> createState() => _MedicinaliScreenState();
}

class _MedicinaliScreenState extends State<MedicinaliScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bottone Indietro
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(width: 10),

                  // Icona (Ridimensionata per stare nella riga)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: ColorPalette.accentMediumOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication_liquid,
                      color: Colors.white,
                      size: 28, // Ridotto da 40
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Titolo
                  const Expanded(
                    child: Text(
                      "Medicinali",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28, // Adattato
                        fontWeight: FontWeight.w900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

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
                          return _MedicinaleTile(
                            text: provider.medicinali[index].name,
                            onDelete: () async {
                              await provider.removeMedicinale(index);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 30.0,
              ),
              child: InkWell(
                onTap: () => _openDialog(),
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

  // Dialog Helper
  void _openDialog() {
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Annulla",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                if (_textController.text.isNotEmpty) {
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

// Widget estratto per il singolo elemento della lista
class _MedicinaleTile extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;

  const _MedicinaleTile({required this.text, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: ColorPalette.deleteRed,
              size: 28,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
