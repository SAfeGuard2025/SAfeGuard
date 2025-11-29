import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_models/contatto_emergenza.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/style/color_palette.dart';

// Schermata Gestione Contatti di Emergenza
// Permette all'utente di visualizzare, aggiungere e rimuovere contatti di emergenza.
class ContattiEmergenzaScreen extends StatefulWidget {
  const ContattiEmergenzaScreen({super.key});
  @override
  State<ContattiEmergenzaScreen> createState() => _ContattiEmergenzaScreenState();
}

class _ContattiEmergenzaScreenState extends State<ContattiEmergenzaScreen> {
  // Controller per i campi di testo nel dialog
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carica i dati dei contatti dal server all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalProvider>(context, listen: false).loadContacts();
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = ColorPalette.backgroundMidBlue;
    const Color cardColor = ColorPalette.backgroundDarkBlue;
    const Color deleteColor = ColorPalette.deleteRed;

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Header con bottone indietro-
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

            // Titolo e Icona
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: ColorPalette.accentMediumOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_in_talk, color: Colors.blueAccent, size: 40),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Contatti di\nemergenza",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Lista dei Contatti
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  // Consumer: ascolta i cambiamenti nella lista contatti
                  child: Consumer<MedicalProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (provider.contatti.isEmpty) {
                        return const Center(child: Text("Nessun contatto aggiunto", style: TextStyle(color: Colors.white)));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                        itemCount: provider.contatti.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.white.withValues(alpha: 0.1)),
                        itemBuilder: (context, index) {
                          return _buildItem(
                            item: provider.contatti[index],
                            onEdit: () {
                              // Modifica disabilitata
                              _openDialog(isEdit: false);
                            },
                            onDelete: () async {
                              // Chiama il provider per rimuovere l'elemento
                              await provider.removeContatto(index);
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

            // Pulsante Aggiungi Contatto
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
              child: InkWell(
                onTap: () => _openDialog(isEdit: false),
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: ColorPalette.accentControlBlue,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Testo indicativo per il nome
                            Text(
                              "Aggiungi un nome (ruolo)",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(color: Colors.white30, height: 10),
                            // Testo indicativo per il numero
                            Text(
                              "Aggiungi un numero",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Icona Aggiungi
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

  // Widget per il singolo elemento della lista
  Widget _buildItem({
    required ContattoEmergenza item,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Numero di telefono
                Text(
                  item.numero,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // Nome/Ruolo del contatto
                Text(
                  item.nome,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
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

  // Dialog per l'aggiunta di un nuovo contatto
  void _openDialog({required bool isEdit}) {
    _numberController.clear();
    _nameController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorPalette.backgroundDarkBlue ,
          title: const Text(
            "Nuovo contatto",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo Numero
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
                // Filtra solo numeri e il segno '+'
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Numero",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Campo Nome (Ruolo)
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Nome (Ruolo)",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            // Pulsante Annulla
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla", style: TextStyle(color: Colors.white70)),
            ),
            // Pulsante Salva e Logica di Validazione
            ElevatedButton(   //Inserimento di un numero con controllo sui campi vuoti e validazione numerica
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {

                final nome = _nameController.text.trim();
                final numero = _numberController.text.trim();
                if (nome.isEmpty || numero.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Per favore, compila tutti i campi.")),
                  );
                  return;
                }

                final isNumeroValido = RegExp(r'^[0-9+]+$').hasMatch(numero);

                if (!isNumeroValido) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Il numero inserito non è valido (usa solo cifre)."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Aggiunta del contatto tramite provider
                final success = await Provider.of<MedicalProvider>(context, listen: false)
                    .addContatto(nome, numero);

                if (success && context.mounted) {
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