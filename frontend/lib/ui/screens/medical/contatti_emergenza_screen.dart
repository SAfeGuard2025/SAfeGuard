import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_models/contatto_emergenza.dart';
import 'package:frontend/providers/medical_provider.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ui/style/color_palette.dart';

class ContattiEmergenzaScreen extends StatefulWidget {
  const ContattiEmergenzaScreen({super.key});
  @override
  State<ContattiEmergenzaScreen> createState() =>
      _ContattiEmergenzaScreenState();
}

class _ContattiEmergenzaScreenState extends State<ContattiEmergenzaScreen> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                      Icons.phone_in_talk,
                      color: Colors.blueAccent,
                      size: 28, // Ridotto da 40
                    ),
                  ),

                  const SizedBox(width: 15),

                  // Titolo
                  const Expanded(
                    child: Text(
                      "Contatti Emergenza",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Adattato
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
                      if (provider.contatti.isEmpty) {
                        return const Center(
                          child: Text(
                            "Nessun contatto aggiunto",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 10.0,
                        ),
                        itemCount: provider.contatti.length,
                        separatorBuilder: (context, index) =>
                            Divider(color: Colors.white.withValues(alpha: 0.1)),
                        itemBuilder: (context, index) {
                          return _ContactTile(
                            item: provider.contatti[index],
                            onDelete: () async {
                              await provider.removeContatto(index);
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
                            Text(
                              "Aggiungi un nome (ruolo)",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(color: Colors.white30, height: 10),
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

  // Dialog Helper
  void _openDialog() {
    _numberController.clear();
    _nameController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorPalette.backgroundDarkBlue,
          title: const Text(
            "Nuovo contatto",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.phone,
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
                final nome = _nameController.text.trim();
                final numero = _numberController.text.trim();

                if (nome.isEmpty || numero.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Per favore, compila tutti i campi."),
                    ),
                  );
                  return;
                }

                // Validazione semplice numero
                if (!RegExp(r'^[0-9+]+$').hasMatch(numero)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Numero non valido (usa solo cifre e +)."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final success = await Provider.of<MedicalProvider>(
                  context,
                  listen: false,
                ).addContatto(nome, numero);

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

// Widget estratto per la Tile del contatto
class _ContactTile extends StatelessWidget {
  final ContattoEmergenza item;
  final VoidCallback onDelete;

  const _ContactTile({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.numero,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                // Nome (più piccolo)
                Text(
                  item.nome,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
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
