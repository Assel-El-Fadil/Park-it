import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/modules/reservation/repositories/reservation_repository.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/common_bottom_nav.dart';
import 'package:src/shared/widgets/section_header.dart';
import 'package:src/core/config/themes/app_theme.dart';

final userReservationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  final repo = ref.read(reservationRepositoryProvider);
  final userId = int.tryParse(user.id) ?? 0;
  return repo.getReservationsWithSpots(userId);
});

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reservationsAsync = ref.watch(userReservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (reservations) {
          if (reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings found',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              final spot = res['parking_spots'] as Map<String, dynamic>?;
              final status = res['status'] as String;
              final startTime = DateTime.parse(res['start_time'] as String);
              final totalPrice = (res['total_price'] as num).toDouble();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              spot?['title'] ?? 'Parking Spot',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _StatusBadge(status: status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a').format(startTime),
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${totalPrice.toStringAsFixed(2)} MAD',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),

                            ],
                          ),
                          if (status.toUpperCase() == 'PENDING')
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: TextButton(
                                onPressed: () {
                                  final booking = ReservationModel.fromJson(res);
                                  context.push(PaymentRoutes.paymentPath, extra: booking);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                child: const Text('Continue Payment'),
                              ),
                            ),
                          TextButton(
                            onPressed: () {
                              context.push('/reservations/${res['id']}');
                            },
                            child: const Text('View Details'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 1),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color color;
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'CANCELLED':
        color = theme.colorScheme.error;
        break;
      default:
        color = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
