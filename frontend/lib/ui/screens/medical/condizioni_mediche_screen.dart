import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/medical_provider.dart';
import 'package:frontend/ui/style/color_palette.dart';

class CondizioniMedicheScreen extends StatefulWidget {
  const CondizioniMedicheScreen({super.key});

  @override
  State<CondizioniMedicheScreen> createState() =>
      _CondizioniMedicheScreenState();
}

class _CondizioniMedicheScreenState extends State<CondizioniMedicheScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalProvider>(context, listen: false).loadCondizioni();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = ColorPalette.backgroundMidBlue;
    const Color cardColor = ColorPalette.backgroundDarkBlue;

    return Scaffold(
      backgroundColor: bgColor,
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

                  const SizedBox(width: 10), // Spaziatura dalla freccia
                  // Icona
                  const CircleAvatar(
                    radius: 24, // Ridotto da 35 per stare in riga
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_3, color: Colors.white, size: 28),
                  ),

                  const SizedBox(width: 15),

                  // Titolo
                  const Expanded(
                    child: Text(
                      "Condizioni Mediche", // Rimossa l'andata a capo (\n)
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Adattato per stare su una riga
                        fontWeight: FontWeight.w900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10), // Ridotto spazio verticale

            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Consumer<MedicalProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final cond = provider.condizioni;

                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _ConditionTile(
                            title: "Disabilità motorie",
                            value: cond.disabilitaMotorie,
                            onChanged: (val) => provider.updateCondizioni(
                              cond.copyWith(disabilitaMotorie: val),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _ConditionTile(
                            title: "Disabilità visive",
                            value: cond.disabilitaVisive,
                            onChanged: (val) => provider.updateCondizioni(
                              cond.copyWith(disabilitaVisive: val),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _ConditionTile(
                            title: "Disabilità uditive",
                            value: cond.disabilitaUditive,
                            onChanged: (val) => provider.updateCondizioni(
                              cond.copyWith(disabilitaUditive: val),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _ConditionTile(
                            title: "Disabilità intellettive",
                            value: cond.disabilitaIntellettive,
                            onChanged: (val) => provider.updateCondizioni(
                              cond.copyWith(disabilitaIntellettive: val),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _ConditionTile(
                            title: "Disabilità psichiche",
                            value: cond.disabilitaPsichiche,
                            onChanged: (val) => provider.updateCondizioni(
                              cond.copyWith(disabilitaPsichiche: val),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ConditionTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConditionTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: ColorPalette.primaryOrange,
              activeTrackColor: Colors.white.withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey.shade300,
              inactiveTrackColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
