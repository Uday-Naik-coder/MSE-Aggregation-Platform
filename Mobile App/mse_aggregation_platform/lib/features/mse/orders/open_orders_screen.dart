import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/order_card.dart';
import 'mse_orders_controller.dart';

class OpenOrdersScreen extends ConsumerWidget {
  const OpenOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(openOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Open Orders')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(openOrdersProvider.future),
        child: orders.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(openOrdersProvider.future)),
          data: (list) => list.isEmpty
              ? const EmptyState(message: 'No open orders available.',
                  subtitle: 'Check back later for new opportunities.',
                  icon: Icons.shopping_bag_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (_, i) => OrderCard(
                    order: list[i],
                    onTap: () => context.go('/mse/orders/${list[i].id}'),
                    trailing: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                      onPressed: () => context.go('/mse/orders/${list[i].id}'),
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('View & Select'),
                    ),
                  )),
        ),
      ),
    );
  }
}
