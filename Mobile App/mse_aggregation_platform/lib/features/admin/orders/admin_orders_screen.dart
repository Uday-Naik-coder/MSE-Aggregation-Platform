import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/order_card.dart';
import 'orders_controller.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(adminOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/orders/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminOrdersProvider.future),
        child: orders.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(adminOrdersProvider.future)),
          data: (list) => list.isEmpty
              ? const EmptyState(message: 'No orders yet.', subtitle: 'Tap + to create the first order.',
                  icon: Icons.list_alt_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (_, i) => OrderCard(order: list[i])),
        ),
      ),
    );
  }
}
