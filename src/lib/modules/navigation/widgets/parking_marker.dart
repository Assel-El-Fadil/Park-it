import 'package:flutter/material.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';

class ParkingMarker extends StatelessWidget {
  const ParkingMarker({
    super.key,
    required this.spot,
    required this.isSelected,
    required this.colorScheme,
  });

  final ParkingSpotModel spot;
  final bool isSelected;
  final ColorScheme colorScheme;

  Color get _markerColor {
    return switch (spot.status) {
      SpotStatus.available => colorScheme.primary,
      SpotStatus.occupied => colorScheme.error,
      SpotStatus.reserved => colorScheme.tertiary,
      SpotStatus.maintenance => colorScheme.outline,
      _ => colorScheme.secondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _markerColor;
    final size = isSelected ? 52.0 : 44.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : color.withOpacity(0.3),
          width: isSelected ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isSelected ? 0.5 : 0.25),
            blurRadius: isSelected ? 14 : 6,
            spreadRadius: isSelected ? 2 : 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_parking_rounded,
            color: Colors.white,
            size: isSelected ? 22 : 18,
          ),
          Text(
            '\$${spot.pricePerHour.toStringAsFixed(0)}/h',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSelected ? 9 : 8,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
