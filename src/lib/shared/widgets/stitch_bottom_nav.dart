import 'dart:ui';

import 'package:flutter/material.dart';

class StitchBottomNav extends StatelessWidget {
  const StitchBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<StitchBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.brightness == Brightness.light
        ? Colors.white.withValues(alpha: 0.92)
        : theme.colorScheme.surface.withValues(alpha: 0.86);

    return SafeArea(
      top: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 18),
              child: Row(
                children: [
                  for (final (i, item) in items.indexed)
                    Expanded(
                      child: InkWell(
                        onTap: () => onChanged(i),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: _NavItemView(
                            item: item,
                            selected: i == index,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StitchBottomNavItem {
  const StitchBottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _NavItemView extends StatelessWidget {
  const _NavItemView({required this.item, required this.selected});

  final StitchBottomNavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(selected ? item.selectedIcon : item.icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(
          item.label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            letterSpacing: 1.0,
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }
}

