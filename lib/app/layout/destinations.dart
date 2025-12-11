import 'package:flutter/material.dart';

class Destination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const Destination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

const List<Destination> doctorDestinations = [
  Destination(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
  ),
  Destination(
    label: 'Capture',
    icon: Icons.camera_alt_outlined,
    selectedIcon: Icons.camera_alt,
  ),
  Destination(
    label: 'Screenings',
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
  ),
  Destination(
    label: 'Profile',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];
