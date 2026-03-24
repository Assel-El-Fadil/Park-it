import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/admin/repositories/admin_repository.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/shared/widgets/app_card.dart';

final adminSpotsProvider = FutureProvider.autoDispose<List<ParkingSpotModel>>((ref) {
  return ref.read(adminRepositoryProvider).getAllSpots();
});

class AdminSpotSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateSearch(String val) => state = val;
}

final adminSpotSearchProvider = NotifierProvider<AdminSpotSearchNotifier, String>(
  AdminSpotSearchNotifier.new,
);

class AdminSpotsScreen extends ConsumerWidget {
  const AdminSpotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminSpotsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Parking Spots'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => ref.read(adminSpotSearchProvider.notifier).updateSearch(val),
              decoration: const InputDecoration(
                hintText: 'Search spots...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (spots) {
          final searchQuery = ref.watch(adminSpotSearchProvider).toLowerCase();
          final filteredSpots = spots.where((spot) {
            final title = spot.title.toLowerCase();
            return title.contains(searchQuery);
          }).toList();

          if (filteredSpots.isEmpty) {
            return const Center(child: Text('No spots found.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminSpotsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredSpots.length,
              itemBuilder: (context, index) {
                final spot = filteredSpots[index];
                final isSuspended = spot.status == SpotStatus.suspended;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: theme.colorScheme.surfaceVariant,
                                image: (spot.photos?.isNotEmpty == true)
                                    ? DecorationImage(
                                        image: NetworkImage(spot.photos!.first),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: (spot.photos?.isEmpty ?? true)
                                  ? const Icon(Icons.local_parking, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    spot.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${spot.street ?? ""}, ${spot.city ?? ""}'.trim(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSuspended ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      spot.status.name.toUpperCase(),
                                      style: TextStyle(
                                        color: isSuspended ? Colors.red : Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _SpotActionToggle(spot: spot),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SpotActionToggle extends ConsumerStatefulWidget {
  const _SpotActionToggle({required this.spot});
  final ParkingSpotModel spot;

  @override
  ConsumerState<_SpotActionToggle> createState() => _SpotActionToggleState();
}

class _SpotActionToggleState extends ConsumerState<_SpotActionToggle> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isSuspended = widget.spot.status == SpotStatus.suspended;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (isSuspended) {
      return OutlinedButton.icon(
        onPressed: () => _toggleStatus(SpotStatus.available),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Unsuspend Spot'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
          minimumSize: const Size(140, 40),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _toggleStatus(SpotStatus.suspended),
      icon: const Icon(Icons.block),
      label: const Text('Suspend Spot'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        minimumSize: const Size(140, 40),
      ),
    );
  }

  Future<void> _toggleStatus(SpotStatus targetStatus) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(adminRepositoryProvider).updateSpotStatus(
            spotId: widget.spot.id,
            status: targetStatus,
          );
      ref.invalidate(adminSpotsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
