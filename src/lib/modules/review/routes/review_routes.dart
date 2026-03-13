import 'package:go_router/go_router.dart';
import 'package:src/modules/review/screens/review_detail_screen.dart';
import 'package:src/modules/review/screens/reviews_screen.dart';

/// Review module route names
class ReviewRoutes {
  // Route names
  static const String reviews = 'reviews';
  static const String addReview = 'add-review';
  static const String reviewDetail = 'review-detail';
  static const String reviewPhotos = 'review-photos';

  // Paths
  static const String reviewsPath = '/reviews';
  static const String addReviewPath = '/reviews/add';
  static const String reviewDetailPath = '/reviews/:id';
  static const String reviewPhotosPath = '/reviews/:id/photos';
}

/// Review module route configuration
List<GoRoute> getReviewRoutes() {
  return [
    // List all reviews
    GoRoute(
      path: ReviewRoutes.reviewsPath,
      name: ReviewRoutes.reviews,
      builder: (context, state) => const ReviewsScreen(),
    ),

    // // Add new review
    // GoRoute(
    //   path: ReviewRoutes.addReviewPath,
    //   name: ReviewRoutes.addReview,
    //   builder: (context, state) {
    //     // Get parking space ID from query parameters
    //     final parkingSpaceId = state.uri.queryParameters['spaceId'];
    //     final bookingId = state.uri.queryParameters['bookingId'];

    //     return AddReviewScreen(
    //       parkingSpaceId: parkingSpaceId,
    //       bookingId: bookingId,
    //     );
    //   },
    // ),

    // Review detail (owner can reply from here)
    GoRoute(
      path: ReviewRoutes.reviewDetailPath,
      name: ReviewRoutes.reviewDetail,
      builder: (context, state) {
        final reviewId = state.pathParameters['id'] ?? '';
        return ReviewDetailScreen(reviewId: reviewId);
      },
    ),

    // // Review photos
    // GoRoute(
    //   path: ReviewRoutes.reviewPhotosPath,
    //   name: ReviewRoutes.reviewPhotos,
    //   builder: (context, state) {
    //     final reviewId = state.pathParameters['id'] ?? '';
    //     return ReviewPhotosScreen(reviewId: reviewId);
    //   },
    // ),
  ];
}
