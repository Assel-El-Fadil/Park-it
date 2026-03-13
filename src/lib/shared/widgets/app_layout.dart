import 'package:flutter/material.dart';

/// Simple responsive constraints used across screens.
///
/// Stitch screens are designed for mobile-first, but this keeps content readable
/// on tablets/desktop by clamping width and preserving consistent padding.
class AppLayout extends StatelessWidget {
  const AppLayout({
    super.key,
    required this.child,
    this.maxContentWidth = 560,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final double maxContentWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

