import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/selection_card.dart';
import 'admin_selections_controller.dart';

class CompletedSelectionsScreen extends ConsumerWidget {
  const CompletedSelectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(completedSelectionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Work')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(completedSelectionsProvider.future),
        child: selections.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(completedSelectionsProvider.future)),
          data: (list) => list.isEmpty
              ? const EmptyState(message: 'No completed work yet.',
                  subtitle: 'Completed selections will appear here.',
                  icon: Icons.check_circle_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (_, i) => SelectionCard(
                    selection: list[i],
                    actions: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
                      onPressed: () => context.go('/admin/rate/${list[i].id}'),
                      icon: const Icon(Icons.star_outline_rounded, size: 16),
                      label: const Text('Rate MSE'),
                    ),
                  )),
        ),
      ),
    );
  }
}
