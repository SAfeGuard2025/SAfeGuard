import 'package:flutter/material.dart';
import 'package:frontend/screens/confirmEmergencyScreen.dart';
import 'package:frontend/widgets/navigationBarCittadino.dart';

// 1. CONVERTITA IN STATEFULWIDGET PER GESTIRE LO STATO DELLA NAV BAR
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Definizione dei colori usati nell'app
  static const Color darkBlue = Color(0xFF12345A);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color amberOrange = Color(0xFFFF9800);

  // Stato per l'indice del tab selezionato
  int _selectedIndex = 0;

  // Lista di Widget che rappresentano le pagine
  final List<Widget> _pages = <Widget>[
    // 0: HomePage Content (il contenuto originale)
    const HomePageContent(),
    // 1: Pagina Utente/Medication (Placeholder)
    const Center(
      child: Text(
        "Pagina Utente",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    // 2: Pagina Mappa (Placeholder)
    const Center(
      child: Text(
        "Pagina Mappa",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    // 3: Pagina Notifiche (Placeholder)
    const Center(
      child: Text(
        "Pagina Notifiche",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    // 4: Pagina Impostazioni (Placeholder)
    const Center(
      child: Text(
        "Pagina Impostazioni",
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ];

  // Funzione chiamata dalla CustomBottomNavBar quando un'icona viene toccata
  void _onItemTapped(int index) {
    // Usiamo setState per aggiornare l'indice e forzare il ricaricamento del body
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Il Container principale avvolge tutto il corpo per impostare il colore di sfondo
    return Container(
      color: darkBlue,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // --- BODY: Visualizza il contenuto della pagina selezionata ---
        // Il body mostra il widget corrispondente all'indice _selectedIndex
        body: _pages[_selectedIndex],

        // --- BOTTOM NAVIGATION BAR ---
        // Integrazione della nuova CustomBottomNavBar
        bottomNavigationBar: CustomBottomNavBar(
          // Passiamo la funzione che aggiorna lo stato _selectedIndex
          onIconTapped: _onItemTapped,
        ),
      ),
    );
  }
}

// 2. ESTRAZIONE DEL CONTENUTO DELLA HOME PAGE
// Il contenuto originale della pagina è stato spostato qui.
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  // Definizione dei colori usati nell'app (Referenziati dallo State)
  static const Color darkBlue = _HomePageState.darkBlue;
  static const Color primaryRed = _HomePageState.primaryRed;
  static const Color amberOrange = _HomePageState.amberOrange;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        // Permette lo scroll se lo schermo è piccolo
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Separatore
              const SizedBox(height: 0),
              // 1. NOTIFICA DI EMERGENZA (IN ALTO)
              _buildEmergencyNotification(),
              //Separatore
              const SizedBox(height: 25),
              // 2. MAPPA
              // *** MODIFICA QUI: Uso il nuovo placeholder vuoto ***
              _buildMapPlaceholder(),
              //Altro separatore
              const SizedBox(height: 10),

              // 3. BOTTONE "CONTATTI DI EMERGENZA"
              _buildEmergencyContactsButton(),

              const SizedBox(height: 10),

              // 4. BOTTONE SOS GRANDE
              _buildSosButton(context),

              const SizedBox(height: 30), // Spazio extra
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PER LA NOTIFICA DI EMERGENZA (ROSSE) ---
  Widget _buildEmergencyNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: primaryRed, // Rosso
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Icona dell'Incendio
          Icon(Icons.house_siding_rounded, color: Colors.white, size: 28),
          SizedBox(width: 15),
          // Testo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Incendio",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "Incendio in Via Roma, 14",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET PER IL CONTAINER DELLA MAPPA (VUOTO/PLACEHOLDER) ---
  Widget _buildMapPlaceholder() {
    return Container(
      height: 225,
      width: double.infinity,
      alignment: Alignment.center, // Centra il testo
      decoration: BoxDecoration(
        color: darkBlue.withOpacity(0.8), // Sfondo Blu Scuro
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54, width: 2), // Bordo per visibilità
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, color: Colors.white70, size: 60),
          SizedBox(height: 10),
          Text(
            "Placeholder Mappa",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "(Implementazione futura)",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PER IL BOTTONE "CONTATTI DI EMERGENZA" (ARANCIONE) ---
  Widget _buildEmergencyContactsButton() {
    return ElevatedButton(
      onPressed: () {
        // Logica per aprire i contatti di emergenza
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: amberOrange, // Arancione
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        elevation: 5,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min, // Occupa solo lo spazio necessario
        children: [
          Icon(Icons.person_pin_circle, color: darkBlue, size: 28),
          SizedBox(width: 10),
          Text(
            "Contatti di Emergenza",
            style: TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET PER IL BOTTONE SOS GRANDE ---
  SosButton _buildSosButton(context) {
    final double buttonSize = MediaQuery.of(context).size.width * 0.60;
    return SosButton(size: buttonSize);
  }
}

// --- CLASSI SOS BUTTON e RingPainter (Mantenute) ---

class SosButton extends StatefulWidget {
  final double size;

  const SosButton({super.key, required this.size});

  @override
  State<SosButton> createState() => _SosButtonState();
}

//Questa classe è per costruire il bottone di SOS come oggetto stateful, così da
//lasciare la home stateless e creare l'effetto di caricamento
class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // tempo necessario per SOS
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ConfirmEmergencyScreen(),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // *** ATTENZIONE: Se 'assets/sosbutton.png' non esiste, questo causerà un errore. ***
              // Se vuoi sostituire anche questo con un placeholder Icon/Text, dovrai modificarlo qui.
              image: const DecorationImage(
                image: AssetImage('assets/sosbutton.png'),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ],
      ),
    );
  }
}
