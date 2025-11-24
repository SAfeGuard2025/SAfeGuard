import 'package:flutter/material.dart';

// Definiamo una HomePage (Stateless, visto che è una schermata statica)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Definizione dei colori usati nell'app per mantenere la coerenza
  static const Color darkBlue = Color(0xFF12345A);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color amberOrange = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    // Il Container principale avvolge tutto il corpo per impostare il colore di sfondo
    return Container(
      color: darkBlue,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Rende trasparente lo Scaffold per mostrare il Container scuro

        // --- BODY: Il contenuto centrale della pagina ---
        body: SafeArea(
          child: SingleChildScrollView( // Permette lo scroll se lo schermo è piccolo
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. NOTIFICA DI EMERGENZA (IN ALTO)
                  const SizedBox(height: 20),
                  _buildEmergencyNotification(),

                  const SizedBox(height: 25),

                  // 2. MAPPA
                  _buildMapContainer(),

                  const SizedBox(height: 25),

                  // 3. BOTTONE "CONTATTI DI EMERGENZA"
                  _buildEmergencyContactsButton(),

                  const SizedBox(height: 50),

                  // 4. BOTTONE SOS GRANDE
                  _buildSosButton(context),

                  const SizedBox(height: 30), // Spazio extra prima della Bottom Nav Bar
                ],
              ),
            ),
          ),
        ),

        // --- BOTTOM NAVIGATION BAR ---
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  // --- WIDGET PER LA NOTIFICA DI EMERGENZA (ROSSE) ---
  Widget _buildEmergencyNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET PER IL CONTAINER DELLA MAPPA (SIMULAZIONE) ---
  Widget _buildMapContainer() {
    // Ho usato un Container decorato con un gradiente e un'immagine placeholder
    // per simulare l'aspetto della mappa centrata su Salerno.
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
        // Simulo un'immagine di sfondo per la mappa
        image: const DecorationImage(
          image: AssetImage('assets/salerno_map_placeholder.png'),
          fit: BoxFit.cover,
        ),
        // Se non hai l'immagine, puoi usare questo per un blocco grigio:
        // color: Colors.grey.shade300,
      ),
      // Puoi aggiungere un widget `ClipRRect` e `Image.asset` se vuoi
      // inserire l'immagine mostrata nel tuo screenshot in modo più preciso.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        // Ho commentato l'Image.asset per non creare un errore
        // se l'utente non ha l'asset: 'assets/salerno_map.png'
        /* child: Image.asset(
          'assets/salerno_map.png',
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Center(child: Text("Mappa Placeholder", style: TextStyle(color: Colors.black))),
        ),
        */
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
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
  Widget _buildSosButton(BuildContext context) {
    // Otteniamo la larghezza dello schermo per dimensionare il pulsante
    final double buttonSize = MediaQuery.of(context).size.width * 0.55;

    return GestureDetector(
      onLongPress: () {
        // Implementa la logica di attivazione dell'SOS (es. tieni premuto)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SOS attivato!"), duration: Duration(seconds: 1)),
        );
      },
      onTap: () {
        // Potresti usare un popup per la conferma prima di chiamare l'emergenza
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tieni premuto per attivare l'SOS!"), duration: Duration(seconds: 1)),
        );
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          // Bordo esterno bianco
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          // Bordo interno rosso chiaro/grigio
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              spreadRadius: 8,
              blurRadius: 15,
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: primaryRed, // Rosso
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              "SOS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET PER LA NAV BAR INFERIORE ---
  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: darkBlue,
      type: BottomNavigationBarType.fixed, // Per avere un background fisso
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      currentIndex: 0, // Impostiamo la Home come selezionata
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0, // Rimuove l'ombra della barra
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled, size: 28),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined, size: 28),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined, size: 28),
          label: 'Mappa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none, size: 28),
          label: 'Notifiche',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined, size: 28),
          label: 'Impostazioni',
        ),
      ],
      onTap: (index) {
        // Implementa la logica di navigazione qui
        // Esempio: print("Toccata icona: $index");
      },
    );
  }
}

// --- CLASSE MAIN PER TESTARE (OPZIONALE) ---
/*
void main() {
  // Aggiungi questo in un file separato (o usa il tuo file main.dart)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
*/