import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/custom_bottom_nav_bar.dart';
import 'package:frontend/ui/screens/home/home_page_content.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/auth_provider.dart';
import '../profile/profile_settings_screen.dart';
import 'package:frontend/ui/screens/map/map_screen.dart';
import 'package:frontend/ui/screens/reports/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePageContent(),       // 0. HOME
    const ReportsScreen(),         // 1. REPORT
    const MapScreen(),             // 2. MAPPA
    const Center(                  // 3. AVVISI
      child: Text(
        "Avvisi\n(In lavorazione)",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    const ProfileSettingsScreen(), // 4. IMPOSTAZIONI
  ];

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRescuer = context.watch<AuthProvider>().isRescuer;

    final backgroundColor = Color(isRescuer ? 0xFFef923d : 0xFF0e2a48);
    final selectedColor = isRescuer ? const Color(0xFF0e2a48) : const Color(0xFFef923d);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth >= 1100;

        return Scaffold(
          backgroundColor: backgroundColor,
          bottomNavigationBar: isDesktop
              ? null
              : CustomBottomNavBar(onIconTapped: _onTabChange),

          body: Row(
            children: [
              if (isDesktop)
                NavigationRail(
                  backgroundColor: Colors.white,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabChange,
                  labelType: NavigationRailLabelType.all,
                  indicatorColor: selectedColor.withValues(alpha: 0.2),
                  selectedIconTheme: IconThemeData(color: selectedColor),
                  selectedLabelTextStyle: TextStyle(
                      color: selectedColor,
                      fontWeight: FontWeight.bold
                  ),
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.assignment_outlined),
                      selectedIcon: Icon(Icons.assignment),
                      label: Text('Report'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map),
                      label: Text('Mappa'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications),
                      label: Text('Avvisi'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profilo'),
                    ),
                  ],
                ),

              if (isDesktop)
                const VerticalDivider(thickness: 1, width: 1),

              // Contenuto centrale
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: _currentIndex == 2 ? double.infinity : 1200,
                      ),
                      child: IndexedStack(
                        index: _currentIndex,
                        children: _pages,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}