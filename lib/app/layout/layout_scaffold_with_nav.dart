import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serfix/app/layout/destinations.dart';
import 'package:serfix/app/themes/app_colors.dart';

class LayoutScaffoldWithNav extends StatelessWidget {
  const LayoutScaffoldWithNav({
    required this.navigationShell,
    required this.shellLocation,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String shellLocation;

  String _getAppBarTitle() {
    final cleanPath = shellLocation.replaceAll('/doctor', '');

    switch (cleanPath) {
      case '/dashboard':
        return 'SERFIX';
      case '/capture':
        return 'Capture';
      case '/screenings':
        return 'Screenings';
      case '/profile':
        return 'Profile';
      default:
        return 'SERFIX';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = _getAppBarTitle();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appBarTitle,
          style: TextStyle(
            letterSpacing: appBarTitle == 'SERFIX' ? 2.0 : null,
            fontWeight: appBarTitle == 'SERFIX' ? FontWeight.bold : null,
          ),
        ),
        centerTitle: appBarTitle == 'SERFIX',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.medical_services, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Doctor',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        key: ValueKey<int>(navigationShell.currentIndex),
        destinations: doctorDestinations
            .map(
              (destination) => NavigationDestination(
                icon: Icon(destination.icon),
                label: destination.label,
                selectedIcon: Icon(destination.selectedIcon),
              ),
            )
            .toList(),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
