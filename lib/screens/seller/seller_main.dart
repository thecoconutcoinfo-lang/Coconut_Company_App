// lib/screens/seller/seller_main.dart
import 'package:flutter/material.dart';
import 'seller_home_screen.dart';
import 'seller_about_screen.dart';

class SellerMain extends StatefulWidget {
  const SellerMain({super.key});

  @override
  State<SellerMain> createState() => _SellerMainState();
}

class _SellerMainState extends State<SellerMain> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SellerHomeScreen(),
    const SellerAboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF34EB89),
        unselectedItemColor: Colors.black54,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}
