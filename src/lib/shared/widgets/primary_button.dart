import 'package:flutter/material.dart';

/// Primary CTA matching Stitch: tall, rounded-xl, bold text.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isExpanded = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2)),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.25),
      ),
    );

    if (!isExpanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

