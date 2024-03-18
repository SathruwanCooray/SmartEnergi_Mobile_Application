import 'package:flutter/material.dart';
import 'package:smartenergi/Pages/home_screen.dart';

class FocusModePage extends StatefulWidget {
  const FocusModePage({Key? key}) : super(key: key);

  @override
  _FocusModePageState createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  int selectedIndex = 1; 
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (selectedIndex) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        break;

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Set to false to hide the back button
        title: const Text('Focus Mode'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: 'Focus Mode'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.black,
        onTap: onItemTapped,
      ),
    );
  }
}
