import 'package:flutter/material.dart';
import 'package:src/modules/owner/screens/owner_dashboard_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_spaces_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_lots_screen.dart';
import 'package:src/modules/user/screens/profile_screen.dart';

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
      const OwnerParkingLotsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.garage_outlined),
            activeIcon: Icon(Icons.garage_rounded),
            label: 'Lots',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

