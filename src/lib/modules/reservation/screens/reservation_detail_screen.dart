import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/reservation/repositories/reservation_repository.dart';
import 'package:src/modules/review/repositories/review_repository.dart';
import 'package:src/modules/report/repositories/report_repository.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/section_header.dart';
import 'package:src/core/config/themes/color_palette.dart';

final reservationDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
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
      appBar: AppBar(title: const Text('Booking Details'), centerTitle: true),
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
          final user = ref.watch(currentUserProvider);
          final userId = user?.id;
          final reservationIntId = id;
          final spotId =
              (data['spot_id'] as int?) ?? (spot?['id'] as int?) ?? 0;

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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${spot?['street'] ?? ''}, ${spot?['city'] ?? ''}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
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
                        value: DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(startTime),
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: 'End',
                        value: DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(endTime),
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
                    label: vehicle != null
                        ? '${vehicle['brand']} ${vehicle['model']}'
                        : 'Vehicle',
                    value: vehicle?['plate_number'] ?? 'N/A',
                  ),
                ),

                const SizedBox(height: 24),
                const SectionHeader(title: 'PAYMENT SUMMARY'),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Rate',
                        value: '\$${totalPrice.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        label: 'Platform Fee',
                        value: '\$${platformFee.toStringAsFixed(2)}',
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        label: 'Total Paid',
                        value:
                            '\$${(totalPrice + platformFee).toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
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
                if (status.toUpperCase() == 'PENDING' ||
                    status.toUpperCase() == 'CONFIRMED')
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Implement cancel
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text('Cancel Reservation'),
                  ),
                const SizedBox(height: 12),
                if (userId != null)
                  FutureBuilder<bool>(
                    future: ref
                        .read(reservationRepositoryProvider)
                        .canUserReviewOrReport(
                          reservationId: reservationIntId,
                          driverId: userId,
                        ),
                    builder: (context, eligibilitySnap) {
                      final canReview = eligibilitySnap.data == true;
                      if (!canReview) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final hasReview = await ref
                                  .read(reservationRepositoryProvider)
                                  .hasExistingReview(reservationIntId);
                              if (hasReview) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'You already reviewed this booking.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (!context.mounted) return;
                              await _showReviewDialog(
                                context,
                                ref,
                                reservationId: reservationIntId,
                                reviewerId: userId,
                                spotId: spotId,
                              );
                            },
                            icon: const Icon(Icons.rate_review_outlined),
                            label: const Text('Leave a review'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _showReportDialog(
                                context,
                                ref,
                                reporterId: userId,
                                targetSpotId: spotId,
                              );
                            },
                            icon: const Icon(Icons.flag_outlined),
                            label: const Text('Report this spot'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                          ),
                        ],
                      );
                    },
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

  Future<void> _showReviewDialog(
    BuildContext context,
    WidgetRef ref, {
    required int reservationId,
    required String reviewerId,
    required int spotId,
  }) async {
    int rating = 5;
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave a review'),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // DropdownButtonFormField<int>(
                  //   initialValue: rating,
                  //   decoration: const InputDecoration(labelText: 'Rating'),
                  //   items: List.generate(
                  //     5,
                  //     (i) => DropdownMenuItem(
                  //       value: i + 1,
                  //       child: Text('${i + 1} stars'),
                  //     ),
                  //   ),
                  //   onChanged: (v) => setLocalState(() => rating = v ?? 5),
                  // ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Comment'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    if (result != true) return;
    await ref
        .read(reviewRepositoryProvider)
        .createReview(
          reservationId: reservationId,
          reviewerId: reviewerId,
          spotId: spotId,
          rating: rating,
          comment: controller.text,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Review submitted.')));
  }

  Future<void> _showReportDialog(
    BuildContext context,
    WidgetRef ref, {
    required String reporterId,
    required int targetSpotId,
  }) async {
    ReportReason reason = ReportReason.fakeListing;
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report parking spot'),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // DropdownButtonFormField<ReportReason>(
                  //   initialValue: reason,
                  //   decoration: const InputDecoration(labelText: 'Reason'),
                  //   items: ReportReason.values
                  //       .map(
                  //         (e) => DropdownMenuItem(
                  //           value: e,
                  //           child: Text(e.toJson()),
                  //         ),
                  //       )
                  //       .toList(),
                  //   onChanged: (v) => setLocalState(
                  //     () => reason = v ?? ReportReason.fakeListing,
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
    if (result != true) return;
    await ref
        .read(reportRepositoryProvider)
        .createSpotReport(
          reporterId: reporterId,
          targetSpotId: targetSpotId,
          reason: reason,
          description: controller.text,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report submitted.')));
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
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
