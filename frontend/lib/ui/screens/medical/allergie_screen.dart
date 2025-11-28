import 'package:flutter/material.dart';
// --- IMPORTA IL MODELLO ---
import 'package:data_models/medical_item.dart';
import 'package:provider/provider.dart';

import '../../../providers/medical_provider.dart';

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
    // Carica i dati veri dal server quando apri la pagina
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
    // ... tieni le costanti dei colori ...
    const Color bgColor = Color(0xFF12345A);
    const Color cardColor = Color(0xFF0E2A48);
    const Color deleteColor = Color(0xFFFF5555);
    const Color addBtnColor = Color(0xFF152F4E);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ... tieni HEADER e TITOLO uguali a prima ...
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // TITOLO (Copia pure quello di prima)
            const SizedBox(height: 30),

            // LISTA COLLEGATA AL PROVIDER
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),

                  // QUI USIAMO IL CONSUMER
                  child: Consumer<MedicalProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.allergie.isEmpty) {
                        return const Center(child: Text("Nessuna allergia", style: TextStyle(color: Colors.white)));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        itemCount: provider.allergie.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withValues(alpha: 0.1),
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          return _buildItem(
                            text: provider.allergie[index].name,
                            // Nota: la modifica di una stringa in array semplice è complessa (di solito si cancella e ricrea),
                            // per semplicità qui permettiamo solo cancellazione o creazione nuova,
                            // o implementi un updateApi specifico.
                            onEdit: () {
                              // Per ora disabilitiamo edit diretto o lo gestiamo come delete+add
                              _openDialog(isEdit: false);
                            },
                            onDelete: () async {
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

            // BOTTONE AGGIUNGI
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
              child: InkWell(
                onTap: () => _openDialog(isEdit: false),
                child: Container(
                  height: 60,
                  // ... Stile bottone uguale a prima ...
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                    color: addBtnColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Aggiungi un’allergia", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.add_circle_outline, color: Colors.greenAccent[400], size: 32),
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
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 26),
                onPressed: onEdit,
              ),
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

  void _openDialog({required bool isEdit, int? index}) {
    _textController.clear(); // Puliamo sempre per ora

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0E2A48),
          title: const Text("Nuova allergia", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Inserisci nome...",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                if (_textController.text.isNotEmpty) {
                  // CHIAMATA AL PROVIDER
                  final success = await Provider.of<MedicalProvider>(context, listen: false)
                      .addAllergia(_textController.text);

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
