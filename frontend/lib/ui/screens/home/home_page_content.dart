import 'package:flutter/material.dart';
import 'package:frontend/ui/screens/auth/registration_screen.dart';
import 'package:frontend/ui/screens/home/confirm_emergency_screen.dart';
import 'package:frontend/ui/screens/medical/contatti_emergenza_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/ui/widgets/emergency_item.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  final Color darkBlue = const Color(0xFF041528);
  final Color primaryRed = const Color(0xFFE53935);
  final Color amberOrange = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final bool isWideScreen = screenWidth > 600;

    final double horizontalPadding = isWideScreen ? screenWidth * 0.08 : 15.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // 1. Mappa
          Expanded(
            flex: isRescuer ? 4 : 5,
            child: _buildMapPlaceholder(isWideScreen),
          ),

          const SizedBox(height: 10),

          // 2. Pulsante contatti
          if (!isRescuer) ...[
            _buildEmergencyContactsButton(context, isWideScreen),
            const SizedBox(height: 10),
          ],

          // 3. Sos button
          Expanded(
            flex: 3,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildSosSection(context),
              ),
            ),
          ),

          // 4. Menù emergenze specifiche (Solo Soccorritore)
          if (isRescuer) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: _buildSpecificEmergency(context, isWideScreen),
            ),
          ],

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildMapPlaceholder(bool isWideScreen) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF0E2A48),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
              child: Icon(Icons.map_outlined, color: Colors.white70, size: isWideScreen ? 80 : 50)
          ),
          const SizedBox(height: 10),
          Text(
            "Mappa",
            style: TextStyle(
              color: Colors.white70,
              fontSize: isWideScreen ? 28 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "(Futura)",
            style: TextStyle(
                color: Colors.white70,
                fontSize: isWideScreen ? 18 : 14
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsButton(BuildContext context, bool isWideScreen) {
    final isLogged = context.watch<AuthProvider>().isLogged;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: isLogged ? amberOrange : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      padding: EdgeInsets.symmetric(
          horizontal: isWideScreen ? 60 : 30,
          vertical: isWideScreen ? 20 : 12
      ),
      elevation: 5,
    );

    final textStyle = TextStyle(
      color: darkBlue,
      fontWeight: FontWeight.bold,
      fontSize: isWideScreen ? 22 : 16,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ElevatedButton(
        onPressed: () {
          final route = isLogged
              ? MaterialPageRoute(builder: (_) => const ContattiEmergenzaScreen())
              : MaterialPageRoute(builder: (_) => const RegistrationScreen());
          Navigator.push(context, route);
        },
        style: buttonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(isLogged) Icon(Icons.person_pin_circle, color: darkBlue, size: isWideScreen ? 34 : 24),
            if(isLogged) const SizedBox(width: 10),
            Text(isLogged ? "Contatti di Emergenza" : "Registrati", style: textStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildSosSection(BuildContext context) {
    final isLogged = context.watch<AuthProvider>().isLogged;
    if (!isLogged) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ConfirmEmergencyScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
          image: const DecorationImage(
            image: AssetImage('assets/sosbutton.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecificEmergency(BuildContext context, bool isWideScreen) {
    return SizedBox(
      width: isWideScreen ? 500 : double.infinity,
      child: EmergencyDropdownMenu(
          items: [
            EmergencyItem(label: "Terremoto", icon: Icons.waves),
            EmergencyItem(label: "Incendio", icon: Icons.local_fire_department),
            EmergencyItem(label: "Tsunami", icon: Icons.water),
            EmergencyItem(label: "Alluvione", icon: Icons.flood),
            EmergencyItem(label: "Malessere", icon: Icons.medical_services),
            EmergencyItem(label: "Bomba", icon: Icons.warning),
          ],
          onSelected: (item) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Selezionato: ${item.label}"), backgroundColor: Colors.black),
            );
          }
      ),
    );
  }
}