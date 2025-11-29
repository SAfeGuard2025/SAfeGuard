import 'package:flutter/material.dart';

// Schermata Report Specifico
// Placeholder per la sezione dedicata ai report o statistiche dettagliate.
class ReportsScreen extends StatefulWidget{
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context)
  {
    return Center(
      child: Text(
        "Report specifico\n(In lavoramento)",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}