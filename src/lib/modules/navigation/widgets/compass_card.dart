import 'dart:math' as math;

import 'package:flutter/material.dart';

class CompassCard extends StatelessWidget {
  const CompassCard({
    super.key,
    required this.bearing,
    required this.colorScheme,
    required this.theme,
  });

  final double? bearing;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final bg = colorScheme.surfaceContainerHighest;
    final fg = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.compass_calibration_rounded, color: fg, size: 18),
          const SizedBox(height: 8),
          Text(
            'Compass',
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: SizedBox(
              width: 44,
              height: 44,
              child: CustomPaint(
                painter: _CompassPainter(
                  bearing: bearing ?? 0,
                  color: colorScheme.primary,
                  trackColor: colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter({
    required this.bearing,
    required this.color,
    required this.trackColor,
  });

  final double bearing;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final tickPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final outer = Offset(
        center.dx + (radius - 2) * math.sin(angle),
        center.dy - (radius - 2) * math.cos(angle),
      );
      final inner = Offset(
        center.dx + (radius - 7) * math.sin(angle),
        center.dy - (radius - 7) * math.cos(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    final angle = bearing * math.pi / 180;
    final needleTip = Offset(
      center.dx + (radius - 10) * math.sin(angle),
      center.dy - (radius - 10) * math.cos(angle),
    );
    final needleTail = Offset(
      center.dx - 8 * math.sin(angle),
      center.dy + 8 * math.cos(angle),
    );
    canvas.drawLine(
      needleTail,
      needleTip,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(center, 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.bearing != bearing;
}
