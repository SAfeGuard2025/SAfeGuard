import 'package:flutter/material.dart';

// Helper per i colori
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode";
  }
  return Color(int.parse(hexCode, radix: 16));
}

class AllergieScreen extends StatefulWidget {
  const AllergieScreen({super.key});

  @override
  State<AllergieScreen> createState() => _AllergieScreenState();
}

class _AllergieScreenState extends State<AllergieScreen> {
  // Lista dati (inizialmente popolata come nello screenshot)
  List<String> allergie = [
    "Lattice",
    "Puntura insetti",
    "Paracetamolo",
    "Muffe",
    "Polline",
  ];

  // Controller per il campo di testo nei dialoghi
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = hexToColor("12345a");
    final Color cardColor = hexToColor("0e2a48");
    final Color deleteIconColor = hexToColor("ff5555"); // Rosso chiaro per il cestino
    final Color addBtnColor = hexToColor("152f4e"); // Colore bottone aggiungi

    return Scaffold(
      backgroundColor: bgColor,
      // ResizeToAvoidBottomInset false evita che la tastiera rompa il layout
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

            // Icona e Titolo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icona Siringa (Placeholder)
                  const Icon(Icons.vaccines, color: Colors.white70, size: 60),
                  // Se hai l'immagine 3D:
                  // Image.asset("assets/images/syringe_icon.png", height: 60),

                  const SizedBox(width: 20),
                  const Text(
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

            // --- 2. LISTA ALLERGIE (CARD CENTRALE) ---
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
                    thumbVisibility: true, // Rende la scrollbar sempre visibile come nello screen
                    thickness: 4,
                    radius: const Radius.circular(10),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      itemCount: allergie.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.1),
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        return _buildAllergyItem(
                          text: allergie[index],
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

            // --- 3. BOTTONE AGGIUNGI (In fondo) ---
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
                        "Aggiungi un’allergia",
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

  // --- WIDGET RIGA LISTA ---
  Widget _buildAllergyItem({
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
          // Testo Allergia
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

          // Icone Azioni
          Row(
            children: [
              // Icona Modifica (Matita)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white, size: 26),
                onPressed: onEdit,
                splashRadius: 20,
              ),
              const SizedBox(width: 5),
              // Icona Elimina (Cestino)
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

  // --- LOGICA: ELIMINA VOCE ---
  void _deleteItem(int index) {
    setState(() {
      allergie.removeAt(index);
    });
  }

  // --- LOGICA: APRI DIALOGO (AGGIUNGI O MODIFICA) ---
  void _openDialog({required bool isEdit, int? index}) {
    if (isEdit && index != null) {
      _textController.text = allergie[index];
    } else {
      _textController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: hexToColor("0e2a48"),
          title: Text(
            isEdit ? "Modifica allergia" : "Nuova allergia",
            style: const TextStyle(color: Colors.white),
          ),
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
                    if (isEdit && index != null) {
                      allergie[index] = _textController.text;
                    } else {
                      allergie.add(_textController.text);
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