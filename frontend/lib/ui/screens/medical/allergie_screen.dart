import 'package:flutter/material.dart';
// --- IMPORTA IL MODELLO ---
import 'package:data_models/medical_item.dart';
class AllergieScreen extends StatefulWidget {
  const AllergieScreen({super.key});

  @override
  State<AllergieScreen> createState() => _AllergieScreenState();
}

class _AllergieScreenState extends State<AllergieScreen> {
  // --- MODIFICA: Uso di MedicalItem invece di String ---
  List<MedicalItem> allergie = [
    MedicalItem(name: "Lattice"),
    MedicalItem(name: "Puntura insetti"),
    MedicalItem(name: "Paracetamolo"),
    MedicalItem(name: "Muffe"),
    MedicalItem(name: "Polline"),
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
    const Color addBtnColor = Color(0xFF152F4E);

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
                children: const [
                  Icon(Icons.vaccines, color: Colors.white70, size: 60),
                  SizedBox(width: 20),
                  Text(
                    "Allergie",
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
                    itemCount: allergie.length,
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.white.withOpacity(0.1),
                      thickness: 1,
                    ),
                    itemBuilder: (context, index) {
                      return _buildItem(
                        // --- MODIFICA: Accesso alla proprietà .name ---
                        text: allergie[index].name,
                        onEdit: () => _openDialog(isEdit: true, index: index),
                        onDelete: () => setState(() => allergie.removeAt(index)),
                        deleteColor: deleteColor,
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
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                    color: addBtnColor,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Aggiungi un’allergia",
                        style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
      // --- MODIFICA: Caricamento dal modello ---
      _textController.text = allergie[index].name;
    } else {
      _textController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0E2A48),
          title: Text(isEdit ? "Modifica allergia" : "Nuova allergia", style: const TextStyle(color: Colors.white)),
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
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  setState(() {
                    // --- MODIFICA: Creazione nuovo oggetto MedicalItem ---
                    if (isEdit && index != null) {
                      allergie[index] = MedicalItem(name: _textController.text);
                    } else {
                      allergie.add(MedicalItem(name: _textController.text));
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