import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; 
import 'profile_screen.dart';   
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  final String emailInput;

  const MainScreen({super.key, required this.emailInput});
  
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; 

  List<Widget> get _pages => [
    DashboardScreen(userEmail: widget.emailInput),
    const HistoryScreen(),
    ProfileScreen(userEmail: widget.emailInput), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[800],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}