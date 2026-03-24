import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/report/repositories/report_repository.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/modules/reservation/repositories/reservation_repository.dart';
import 'package:src/modules/review/repositories/review_repository.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/common_bottom_nav.dart';

final userReservationsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final repo = ref.read(reservationRepositoryProvider);
  final userId = user.id;
  return repo.getReservationsWithSpots(userId);
});

final reviewedReservationIdsProvider = FutureProvider<Set<int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};

  final repo = ref.read(reviewRepositoryProvider);
  final reviews = await repo.getReviewsByReviewer(user.id);
  return reviews.map((r) => r.reservationId).toSet();
});

final reportedSpotIdsProvider = FutureProvider<Set<int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};

  // Note: We don't have a getReportsByReporter in ReportRepository yet.
  // For now, we'll return an empty set and implement the UI to show a snackbar if duplicate.
  // Or we can just let Supabase handle the unique constraint if any.
  return {};
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
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Seed test booking',
            onPressed: () async {
              final user = ref.read(currentUserProvider);
              final userId = user?.id;
              if (userId == null) return;
              await ref
                  .read(reservationRepositoryProvider)
                  .seedExampleCompletedReservation(driverId: userId);
              ref.invalidate(userReservationsProvider);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Example completed reservation ready.'),
                ),
              );
            },
            icon: const Icon(Icons.science_outlined),
          ),
        ],
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
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(startTime),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '\$${totalPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (status.toUpperCase() == 'PENDING')
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: TextButton(
                                    onPressed: () {
                                      final booking = ReservationModel.fromJson(
                                        res,
                                      );
                                      context.push(
                                        PaymentRoutes.paymentPath,
                                        extra: booking,
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: theme.colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
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
                      if (status.toUpperCase() == 'COMPLETED') ...[
                        const Divider(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ref
                                  .watch(reviewedReservationIdsProvider)
                                  .when(
                                    data: (reviewedIds) {
                                      final resId = (res['id'] as num?)?.toInt();
                                      final isReviewed = resId != null && reviewedIds.contains(resId);
                                      return OutlinedButton.icon(
                                        onPressed: isReviewed
                                            ? null
                                            : () => _showReviewSheet(
                                                  context,
                                                  ref,
                                                  res,
                                                ),
                                        icon: Icon(
                                          isReviewed
                                              ? Icons.check_circle_outline
                                              : Icons.star_outline,
                                          size: 18,
                                        ),
                                        label: Text(
                                          isReviewed ? 'Reviewed' : 'Review',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isReviewed
                                              ? Colors.green
                                              : theme.colorScheme.primary,
                                          side: BorderSide(
                                            color: isReviewed
                                                ? Colors.green.withOpacity(0.5)
                                                : theme.colorScheme.primary
                                                    .withOpacity(0.5),
                                          ),
                                        ),
                                      );
                                    },
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showReportSheet(
                                  context,
                                  ref,
                                  res,
                                ),
                                icon: const Icon(
                                  Icons.report_problem_outlined,
                                  size: 18,
                                ),
                                label: const Text('Report'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  side: BorderSide(
                                    color: theme.colorScheme.error
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  void _showReviewSheet(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> reservation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReviewSheet(reservation: reservation),
    );
  }

  void _showReportSheet(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> reservation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportSheet(reservation: reservation),
    );
  }
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({required this.reservation});
  final Map<String, dynamic> reservation;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotTitle = widget.reservation['parking_spots']?['title'] ?? 'Parking';

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rate your stay',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(
            spotTitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starValue),
                  icon: Icon(
                    starValue <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 40,
                    color: Colors.amber.shade600,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Review'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw const AppException('User not found');

      final resId = (widget.reservation['id'] as num?)?.toInt();
      final spotId = (widget.reservation['spot_id'] as num?)?.toInt() ?? 
                     (widget.reservation['parking_spots']?['id'] as num?)?.toInt();

      if (resId == null || spotId == null) {
        throw AppException('Missing IDs: res=$resId, spot=$spotId');
      }

      // Final check to prevent duplicate key error
      final hasExisting = await ref.read(reservationRepositoryProvider).hasExistingReview(resId);
      if (hasExisting) {
        ref.invalidate(reviewedReservationIdsProvider);
        throw const AppException('You have already reviewed this reservation.');
      }

      await ref.read(reviewRepositoryProvider).createReview(
            reservationId: resId,
            reviewerId: user.id,
            spotId: spotId,
            rating: _rating,
            comment: _commentController.text,
          );

      if (!mounted) return;
      ref.invalidate(reviewedReservationIdsProvider);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted. Thank you!')),
      );
    } catch (e) {
      debugPrint('Review Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.reservation});
  final Map<String, dynamic> reservation;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason _reason = ReportReason.fakeListing;
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report Issue',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReportReason>(
            value: _reason,
            decoration: InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: ReportReason.values.map((r) {
              return DropdownMenuItem(
                value: r,
                child: Text(r.name
                    .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
                    .trim()
                    .capitalize()),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _reason = val);
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe the problem...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw const AppException('User not found');

      final spotId = (widget.reservation['spot_id'] as num?)?.toInt() ?? 
                     (widget.reservation['parking_spots']?['id'] as num?)?.toInt();

      if (spotId == null) {
        throw const AppException('Parking spot ID not found');
      }

      await ref.read(reportRepositoryProvider).createSpotReport(
            reporterId: user.id,
            targetSpotId: spotId,
            reason: _reason,
            description: _descController.text,
          );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. We will review it.')),
      );
    } catch (e) {
      debugPrint('Report Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
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
