import 'package:flutter/material.dart';

// Helper per i colori
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode";
  }
  return Color(int.parse(hexCode, radix: 16));
}

class MedicinaliScreen extends StatefulWidget {
  const MedicinaliScreen({super.key});

  @override
  State<MedicinaliScreen> createState() => _MedicinaliScreenState();
}

class _MedicinaliScreenState extends State<MedicinaliScreen> {
  // Lista iniziale dei farmaci come da screenshot
  List<String> medicinali = [
    "Anticoagulanti",
    "Beta-bloccanti",
    "Insulina",
    "Corticosteroidi",
    "Antidepressivi",
  ];

  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colori estratti dallo screenshot
    final Color bgColor = hexToColor("12345a");
    final Color cardColor = hexToColor("0e2a48");
    final Color headerIconBgColor = hexToColor("e08e50"); // Arancione del cerchio
    final Color deleteIconColor = hexToColor("ff5555");
    final Color addBtnColor = hexToColor("152f4e");

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER ---
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

            // Icona Cerchio Arancione e Titolo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icona personalizzata (Cerchio arancione con pillole)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: headerIconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication_liquid, // O Icons.local_pharmacy
                      color: Colors.white,
                      size: 45,
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

            // --- 2. LISTA MEDICINALI (CARD) ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: Scrollbar(
                    thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(10),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      itemCount: medicinali.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.1),
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        return _buildMedicineItem(
                          text: medicinali[index],
                          onEdit: () => _openDialog(isEdit: true, index: index),
                          onDelete: () => _deleteItem(index),
                          deleteColor: deleteIconColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- 3. BOTTONE AGGIUNGI ---
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
              child: InkWell(
                onTap: () => _openDialog(isEdit: false),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  decoration: BoxDecoration(
                    color: addBtnColor,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
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
                        color: Colors.greenAccent[400], // Verde acceso
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

  // --- WIDGET RIGA ---
  Widget _buildMedicineItem({
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
          // Nome Farmaco
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

          // Icone
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 26),
                onPressed: onEdit,
                splashRadius: 20,
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: Icon(Icons.delete_outline, color: deleteColor, size: 28),
                onPressed: onDelete,
                splashRadius: 20,
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- LOGICA DI CANCELLAZIONE ---
  void _deleteItem(int index) {
    setState(() {
      medicinali.removeAt(index);
    });
  }

  // --- LOGICA DI AGGIUNTA/MODIFICA (DIALOG) ---
  void _openDialog({required bool isEdit, int? index}) {
    if (isEdit && index != null) {
      _textController.text = medicinali[index];
    } else {
      _textController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: hexToColor("0e2a48"),
          title: Text(
            isEdit ? "Modifica farmaco" : "Nuovo farmaco",
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: _textController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Nome del farmaco...",
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
                    if (isEdit && index != null) {
                      medicinali[index] = _textController.text;
                    } else {
                      medicinali.add(_textController.text);
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