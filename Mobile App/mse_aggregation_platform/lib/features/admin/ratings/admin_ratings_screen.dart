import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/rating_card.dart';
import 'admin_ratings_controller.dart';

class AdminRatingsScreen extends ConsumerWidget {
  const AdminRatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratings = ref.watch(adminRatingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('MSE Ratings')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminRatingsProvider.future),
        child: ratings.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(adminRatingsProvider.future)),
          data: (list) => list.isEmpty
              ? const EmptyState(message: 'No ratings submitted yet.',
                  subtitle: 'Rate completed MSE work from the Completed tab.',
                  icon: Icons.star_outline_rounded)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (_, i) => RatingCard(rating: list[i])),
        ),
      ),
    );
  }
}
