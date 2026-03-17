import 'package:flutter/material.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';

class BottomLegend extends StatelessWidget {
  const BottomLegend({
    super.key,
    required this.spots,
    required this.colorScheme,
  });
  final List<ParkingSpotModel> spots;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final available = spots
        .where((s) => s.status == SpotStatus.available)
        .length;
    final occupied = spots.where((s) => s.status == SpotStatus.occupied).length;
    final reserved = spots.where((s) => s.status == SpotStatus.reserved).length;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.paddingOf(context).bottom + 14,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LegendItem(
            label: 'Available',
            count: available,
            color: colorScheme.primary,
          ),
          _Divider(),
          _LegendItem(
            label: 'Occupied',
            count: occupied,
            color: colorScheme.error,
          ),
          _Divider(),
          _LegendItem(
            label: 'Reserved',
            count: reserved,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
