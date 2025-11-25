import 'package:flutter/material.dart';
// --- IMPORTA IL MODELLO ESTERNO ---
import 'package:data_models/contact_item.dart';

class ContattiEmergenzaScreen extends StatefulWidget {
  const ContattiEmergenzaScreen({super.key});

  @override
  State<ContattiEmergenzaScreen> createState() => _ContattiEmergenzaScreenState();
}

class _ContattiEmergenzaScreenState extends State<ContattiEmergenzaScreen> {
  // Ora la lista usa la classe importata da /models
  List<ContactItem> contacts = [
    ContactItem(number: "+39 333 1234567", nameAndRole: "Giovanna Lamberti (madre)"),
    ContactItem(number: "+39 333 1234566", nameAndRole: "Lorenzo Lamberti (padre)"),
  ];

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
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28), onPressed: () => Navigator.pop(context))
              ]),
            ),

            // TITOLO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 70, height: 70,
                  decoration: const BoxDecoration(color: Color(0xFFE08E50), shape: BoxShape.circle),
                  child: const Icon(Icons.phone_in_talk, color: Colors.blueAccent, size: 40),
                ),
                const SizedBox(width: 20),
                const Text("Contatti di\nemergenza", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.1)),
              ]),
            ),
            const SizedBox(height: 30),

            // LISTA
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(25.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    itemCount: contacts.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.1)),
                    itemBuilder: (context, index) {
                      return _buildItem(
                        item: contacts[index],
                        onEdit: () => _openDialog(isEdit: true, index: index),
                        onDelete: () => setState(() => contacts.removeAt(index)),
                        deleteColor: deleteColor,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // AGGIUNGI (Form Finto che apre dialog)
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
              child: InkWell(
                onTap: () => _openDialog(isEdit: false),
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(color: const Color(0xFF152F4E), borderRadius: BorderRadius.circular(20.0)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Aggiungi un nome (ruolo)", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16, fontWeight: FontWeight.bold)),
                            const Divider(color: Colors.white30, height: 10),
                            Text("Aggiungi un numero", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                          ],
                        ),
                      ),
                      Icon(Icons.add_circle_outline, color: Colors.greenAccent[400], size: 35),
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

  Widget _buildItem({required ContactItem item, required VoidCallback onEdit, required VoidCallback onDelete, required Color deleteColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.number, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(item.nameAndRole, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
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
          backgroundColor: const Color(0xFF0E2A48),
          title: Text(isEdit ? "Modifica contatto" : "Nuovo contatto", style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Numero", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Nome (Ruolo)", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla", style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                if (_numberController.text.isNotEmpty && _nameController.text.isNotEmpty) {
                  setState(() {
                    final item = ContactItem(number: _numberController.text, nameAndRole: _nameController.text);
                    if (isEdit && index != null) contacts[index] = item;
                    else contacts.add(item);
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