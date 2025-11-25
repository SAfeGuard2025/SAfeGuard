import 'package:flutter/material.dart';
// --- IMPORTA IL MODELLO ---
import 'package:data_models/medical_item.dart';

class MedicinaliScreen extends StatefulWidget {
  const MedicinaliScreen({super.key});

  @override
  State<MedicinaliScreen> createState() => _MedicinaliScreenState();
}

class _MedicinaliScreenState extends State<MedicinaliScreen> {
  // --- MODIFICA 1: La lista ora contiene oggetti MedicalItem ---
  List<MedicalItem> medicinali = [
    MedicalItem(name: "Anticoagulanti"),
    MedicalItem(name: "Beta-bloccanti"),
    MedicalItem(name: "Insulina"),
    MedicalItem(name: "Corticosteroidi"),
    MedicalItem(name: "Antidepressivi"),
    ];

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF12345A);
    const Color cardColor = Color(0xFF0E2A48);
    const Color deleteColor = Color(0xFFFF5555);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
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

            // TITOLO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: const BoxDecoration(color: Color(0xFFE08E50), shape: BoxShape.circle),
                    child: const Icon(Icons.medication_liquid, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Medicinali",
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // LISTA
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    itemCount: medicinali.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1)),
                    itemBuilder: (context, index) {
                      return _buildItem(
                        // --- MODIFICA 2: Accediamo alla proprietà .name ---
                          text: medicinali[index].name,
                          onEdit: () => _openDialog(isEdit: true, index: index),
                      onDelete: () => setState(() => medicinali.removeAt(index)),
                      deleteColor: deleteColor,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // AGGIUNGI
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
              child: InkWell(
                onTap: () => _openDialog(isEdit: false),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF152F4E),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Aggiungi un farmaco", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildItem({required String text, required VoidCallback onEdit, required VoidCallback onDelete, required Color deleteColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.white, size: 26), onPressed: onEdit),
              IconButton(icon: Icon(Icons.delete_outline, color: deleteColor, size: 28), onPressed: onDelete),
            ],
          )
        ],
      ),
    );
  }

  void _openDialog({required bool isEdit, int? index}) {
    if (isEdit && index != null) {
      // --- MODIFICA 3: Pre-popoliamo il campo usando .name ---
      _textController.text = medicinali[index].name;
    } else {
      _textController.clear();
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0E2A48),
          title: Text(isEdit ? "Modifica farmaco" : "Nuovo farmaco", style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Nome farmaco...",
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla", style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  setState(() {
                    // --- MODIFICA 4: Creiamo nuovi oggetti MedicalItem ---
                    if (isEdit && index != null) {
                      // Sostituiamo l'oggetto esistente con uno nuovo che ha il nome aggiornato
                      medicinali[index] = MedicalItem(name: _textController.text);
                    } else {
                      // Aggiungiamo un nuovo oggetto
                      medicinali.add(MedicalItem(name: _textController.text));
                    }
                  });
                  Navigator.pop(context);
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