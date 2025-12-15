import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

class AllergieScreen extends StatefulWidget {
  const AllergieScreen({super.key});

  @override
  State<AllergieScreen> createState() => _AllergieScreenState();
}

class _AllergieScreenState extends State<AllergieScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    const Color addBtnColor = ColorPalette.accentControlBlue;

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

                  // Icona
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: ColorPalette.accentMediumOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons
                          .coronavirus_outlined, // O un'icona simile per le allergie
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Titolo
                  const Expanded(
                    child: Text(
                      "Allergie",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
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
                      if (provider.allergie.isEmpty) {
                        return const Center(
                          child: Text(
                            "Nessuna allergia",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

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
                          return _AllergyTile(
                            text: provider.allergie[index].name,
                            onDelete: () async {
                              await provider.removeAllergia(index);
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

  // Dialog Helper
  void _openDialog() {
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
                  ).addAllergia(_textController.text);

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

// Widget estratto per la Tile dell'allergia
class _AllergyTile extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;

  const _AllergyTile({required this.text, required this.onDelete});

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
