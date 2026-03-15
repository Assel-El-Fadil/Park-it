import 'package:flutter/material.dart';
import 'package:src/modules/owner/screens/owner_dashboard_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_spaces_screen.dart';

/// Owner area entry point with bottom navigation.
///
/// This is UI-only: data is mocked for now.
class OwnerShellScreen extends StatefulWidget {
  const OwnerShellScreen({super.key});

  @override
  State<OwnerShellScreen> createState() => _OwnerShellScreenState();
}

class _OwnerShellScreenState extends State<OwnerShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const OwnerDashboardScreen(),
      const OwnerParkingSpacesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_parking_outlined),
            activeIcon: Icon(Icons.local_parking_rounded),
            label: 'Spots',
          ),
        ],
      ),
    );
  }
}

