import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.max = 5,
    this.size = 14,
  });

  final double rating;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor().clamp(0, max);
    final hasHalf = (rating - full) >= 0.5 && full < max;
    final empty = max - full - (hasHalf ? 1 : 0);

    final color = Colors.amber.shade500;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < full; i++)
          Icon(Icons.star_rounded, size: size, color: color),
        if (hasHalf) Icon(Icons.star_half_rounded, size: size, color: color),
        for (var i = 0; i < empty; i++)
          Icon(Icons.star_outline_rounded, size: size, color: color),
      ],
    );
  }
}

