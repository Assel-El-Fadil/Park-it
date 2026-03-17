import 'package:flutter/material.dart';

class MapIconButton extends StatelessWidget {
  const MapIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.colorScheme,
    this.small = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 36.0 : 44.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: colorScheme.onSurface, size: small ? 18 : 22),
      ),
    );
  }
}
