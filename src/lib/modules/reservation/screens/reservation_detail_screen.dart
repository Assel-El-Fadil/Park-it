import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/reservation/repositories/reservation_repository.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/section_header.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/modules/payment/widgets/order_summary.dart';
import 'package:src/modules/reservation/screens/reservations_screen.dart';

final reservationDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
  final repo = ref.read(reservationRepositoryProvider);
  return repo.getReservationWithDetails(id);
});

class ReservationDetailScreen extends ConsumerWidget {
  const ReservationDetailScreen({super.key, required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final id = int.tryParse(reservationId) ?? 0;
    final detailAsync = ref.watch(reservationDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        centerTitle: true,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          final spot = data['parking_spots'] as Map<String, dynamic>?;
          final vehicle = data['vehicles'] as Map<String, dynamic>?;
          final status = data['status'] as String;
          final startTime = DateTime.parse(data['start_time'] as String);
          final endTime = DateTime.parse(data['end_time'] as String);
          final totalPrice = (data['total_price'] as num).toDouble();
          final platformFee = (data['platform_fee'] as num).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(status: status),
                const SizedBox(height: 24),
                
                const SectionHeader(title: 'PARKING SPOT'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot?['title'] ?? 'Parking Spot',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${spot?['street'] ?? ''}, ${spot?['city'] ?? ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                const SectionHeader(title: 'TIME & DURATION'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Start',
                        value: DateFormat('MMM dd, yyyy • hh:mm a').format(startTime),
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: 'End',
                        value: DateFormat('MMM dd, yyyy • hh:mm a').format(endTime),
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: 'Duration',
                        value: _formatDuration(endTime.difference(startTime)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const SectionHeader(title: 'VEHICLE'),
                const SizedBox(height: 12),
                AppCard(
                  child: _DetailRow(
                    label: vehicle != null ? '${vehicle['brand']} ${vehicle['model']}' : 'Vehicle',
                    value: vehicle?['plate_number'] ?? 'N/A',
                  ),
                ),

                const SizedBox(height: 24),
                OrderSummary(
                  amount: totalPrice,
                  platformFee: platformFee,
                  ownerPayout: totalPrice - platformFee,
                  currency: 'MAD',
                ),

                const SizedBox(height: 32),
                if (status.toUpperCase() == 'PENDING') ...[
                  ElevatedButton(
                    onPressed: () {
                      final booking = ReservationModel.fromJson(data);
                      context.push(PaymentRoutes.paymentPath, extra: booking);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text('Pay Now'),
                  ),
                  const SizedBox(height: 12),
                ],
                Builder(
                  builder: (context) {
                    final isPending = status.toUpperCase() == 'PENDING';
                    final isConfirmed = status.toUpperCase() == 'CONFIRMED';
                    final startTimeLabel = data['start_time'];
                    final startDateTime = startTimeLabel != null ? DateTime.parse(startTimeLabel) : DateTime.now();
                    final timeUntilStart = startDateTime.difference(DateTime.now());
                    final canCancel = isPending || (isConfirmed && timeUntilStart.inHours >= 48);

                    if (!canCancel) return const SizedBox.shrink();

                    return OutlinedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancel Reservation?'),
                            content: const Text(
                                'Are you sure you want to cancel this reservation? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('No, keep it'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error),
                                child: const Text('Yes, cancel'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );

                            await ref
                                .read(reservationRepositoryProvider)
                                .cancelReservation(id);

                            if (context.mounted) {
                              Navigator.of(context).pop(); // clear loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Reservation cancelled successfully')),
                              );

                              ref.invalidate(reservationDetailProvider(id));
                              ref.invalidate(userReservationsProvider);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.of(context).pop(); // clear loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text('Cancel Reservation'),
                    );
                  }
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 24) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    }
    return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color color;
    IconData icon;
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
      case 'COMPLETED':
      case 'ACTIVE':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'PENDING':
        color = Colors.orange;
        icon = Icons.info;
        break;
      case 'CANCELLED':
        color = theme.colorScheme.error;
        icon = Icons.cancel;
        break;
      default:
        color = theme.colorScheme.onSurfaceVariant;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            'Reservation is ${status.toLowerCase()}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
