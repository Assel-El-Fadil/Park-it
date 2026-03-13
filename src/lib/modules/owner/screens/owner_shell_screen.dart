import 'package:flutter/material.dart';
import 'package:src/modules/owner/screens/owner_dashboard_screen.dart';
import 'package:src/modules/owner/screens/owner_parking_spaces_screen.dart';
import 'package:src/shared/widgets/stitch_bottom_nav.dart';

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
      bottomNavigationBar: StitchBottomNav(
        index: _index,
        onChanged: (value) => setState(() => _index = value),
        items: const [
          StitchBottomNavItem(
            label: 'Dashboard',
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
          ),
          StitchBottomNavItem(
            label: 'Spots',
            icon: Icons.local_parking_outlined,
            selectedIcon: Icons.local_parking_rounded,
          ),
        ],
      ),
    );
  }
}

