import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/modules/navigation/widgets/map_icon_button.dart';

class BottomInfoStrip extends StatelessWidget {
  const BottomInfoStrip({
    super.key,
    required this.routeState,
    required this.placeName,
    required this.onReroute,
    required this.colorScheme,
    required this.theme,
  });

  final AsyncValue routeState;
  final String placeName;
  final VoidCallback onReroute;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: routeState.when(
        loading: () => const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Calculating route…'),
          ],
        ),
        error: (_, __) => Row(
          children: [
            const Icon(Icons.warning_amber_rounded),
            const SizedBox(width: 8),
            const Expanded(child: Text('Could not load route')),
            TextButton(onPressed: onReroute, child: const Text('Retry')),
          ],
        ),
        data: (route) {
          if (route == null) return const SizedBox.shrink();
          return Row(
            children: [
              Icon(Icons.place_rounded, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      placeName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${route.distanceText}  ·  ${route.durationText}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              MapIconButton(
                icon: Icons.refresh_rounded,
                onTap: onReroute,
                colorScheme: colorScheme,
                small: true,
              ),
            ],
          );
        },
      ),
    );
  }
}
