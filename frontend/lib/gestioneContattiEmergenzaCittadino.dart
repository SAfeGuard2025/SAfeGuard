import 'package:flutter/material.dart';

// Helper per i colori
Color hexToColor(String code) {
  String hexCode = code.toUpperCase().replaceAll("#", "");
  if (hexCode.length == 6) {
    hexCode = "FF$hexCode";
  }
  return Color(int.parse(hexCode, radix: 16));
}

// Modello dati per un contatto
class ContactItem {
  String number;
  String nameAndRole;

  ContactItem({required this.number, required this.nameAndRole});
}

class ContattiEmergenzaScreen extends StatefulWidget {
  const ContattiEmergenzaScreen({super.key});

  @override
  State<ContattiEmergenzaScreen> createState() => _ContattiEmergenzaScreenState();
}

class _ContattiEmergenzaScreenState extends State<ContattiEmergenzaScreen> {
  // Lista contatti inizializzata come nello screenshot
  List<ContactItem> contacts = [
    ContactItem(number: "+39 333 1234567", nameAndRole: "Giovanna Lamberti (madre)"),
    ContactItem(number: "+39 333 1234566", nameAndRole: "Lorenzo Lamberti (padre)"),
    ContactItem(number: "+39 333 1234565", nameAndRole: "Simone Lamberti (fratello)"),
    ContactItem(number: "+39 333 1234564", nameAndRole: "Maria Lamberti (sorella)"),
    ContactItem(number: "+39 333 1234563", nameAndRole: "Anna Lamberti (nonna)"),
  ];

  // Controller per i campi di testo del dialog
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colori
    final Color bgColor = hexToColor("12345a");
    final Color cardColor = hexToColor("0e2a48");
    final Color headerIconBgColor = hexToColor("e08e50"); // Arancione cerchio
    final Color deleteIconColor = hexToColor("ff5555");
    final Color bottomCardColor = hexToColor("152f4e"); // Colore sfondo area input in basso

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
                  // Icona Cornetta
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: headerIconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_in_talk, // Icona telefono
                      color: Colors.blueAccent, // Colore cornetta (simile all'immagine)
                      size: 45,
                    ),
                  ),

                  const SizedBox(width: 20),

                  const Text(
                    "Contatti di\nemergenza",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30, // Leggermente più piccolo per stare su due righe
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. LISTA CONTATTI ---
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
                      itemCount: contacts.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.1),
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        return _buildContactItem(
                          item: contacts[index],
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

            // --- 3. AREA DI AGGIUNTA (Simil-Form) ---
            // Nello screenshot sembra un form statico che funge da bottone
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
              child: InkWell(
                onTap: () => _openDialog(isEdit: false),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 80, // Più alto per contenere due righe di testo
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: bottomCardColor,
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
                    children: [
                      // Testi "Placeholder"
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Aggiungi un nome (ruolo)",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(color: Colors.white30, height: 10),
                            Text(
                              "Aggiungi un numero",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Icona Più
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.greenAccent[400],
                        size: 35,
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

  // --- WIDGET RIGA CONTATTO ---
  Widget _buildContactItem({
    required ContactItem item,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required Color deleteColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info Contatto (Numero e Nome)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.nameAndRole,
                  style: const TextStyle(
                    color: Colors.white70, // Un po' più grigio
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
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

  // --- LOGICA CANCELLAZIONE ---
  void _deleteItem(int index) {
    setState(() {
      contacts.removeAt(index);
    });
  }

  // --- LOGICA DIALOGO (AGGIUNGI/MODIFICA) ---
  void _openDialog({required bool isEdit, int? index}) {
    if (isEdit && index != null) {
      _numberController.text = contacts[index].number;
      _nameController.text = contacts[index].nameAndRole;
    } else {
      _numberController.clear();
      _nameController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: hexToColor("0e2a48"),
          title: Text(
            isEdit ? "Modifica contatto" : "Nuovo contatto",
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo Numero
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Numero di telefono",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
              const SizedBox(height: 10),
              // Campo Nome
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Nome e Ruolo (es. Mamma)",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                if (_numberController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                  setState(() {
                    ContactItem newItem = ContactItem(
                      number: _numberController.text,
                      nameAndRole: _nameController.text,
                    );

                    if (isEdit && index != null) {
                      contacts[index] = newItem;
                    } else {
                      contacts.add(newItem);
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