import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../models/rating_model.dart';
import '../../../services/api_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/rating_card.dart';

final _mseRatingsProvider = FutureProvider.autoDispose<List<RatingModel>>((ref) {
  return ApiService(ref.read(apiClientProvider)).getMyRatings();
});

class MseRatingsScreen extends ConsumerWidget {
  const MseRatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratings = ref.watch(_mseRatingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Ratings')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(_mseRatingsProvider.future),
        child: ratings.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(_mseRatingsProvider.future)),
          data: (list) {
            if (list.isEmpty) {
              return const EmptyState(message: 'No ratings yet.',
                subtitle: 'Complete your approved orders to receive ratings from admin.',
                icon: Icons.star_outline_rounded);
            }
            final avg = list.map((r) => r.overallRating).reduce((a, b) => a + b) / list.length;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Average rating banner
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: AppRadius.lg),
                  child: Column(children: [
                    Text(avg.toStringAsFixed(1), style: const TextStyle(
                      color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700)),
                    const Text('Average Rating', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('Based on ${list.length} review${list.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),
                ...list.map((r) => RatingCard(rating: r)),
              ],
            );
          },
        ),
      ),
    );
  }
}
