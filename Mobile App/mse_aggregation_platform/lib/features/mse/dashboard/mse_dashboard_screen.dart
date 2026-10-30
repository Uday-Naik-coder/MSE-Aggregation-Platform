import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../shared/components/confirm_dialog.dart';
import '../../../shared/widgets/dashboard_stat_card.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import 'mse_dashboard_controller.dart';

class MseDashboardScreen extends ConsumerWidget {
  const MseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user  = ref.watch(authControllerProvider).valueOrNull;
    final stats = ref.watch(mseDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('My Dashboard', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text('Welcome, ${user?.businessName ?? user?.name ?? 'MSE'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final ok = await ConfirmDialog.show(context,
                title: 'Sign Out', message: 'Are you sure you want to sign out?',
                confirmLabel: 'Sign Out', isDanger: true);
              if (ok && context.mounted) {
                await ref.read(authControllerProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(mseDashboardProvider.future),
        child: stats.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(mseDashboardProvider.future)),
          data: (data) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Average rating highlight
              if ((data['avgRating'] ?? 0.0) > 0) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.secondary, AppColors.secondaryDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: AppRadius.lg,
                  ),
                  child: Row(children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 32),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${(data['avgRating'] as num).toStringAsFixed(1)} / 5.0',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      const Text('Your average rating', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.25,
                children: [
                  DashboardStatCard(
                    label: 'Available Orders', value: '${data['availableOrders'] ?? 0}',
                    icon: Icons.shopping_bag_outlined, color: AppColors.primary,
                    onTap: () => context.go('/mse/orders')),
                  DashboardStatCard(
                    label: 'Pending Selections', value: '${data['pendingSelections'] ?? 0}',
                    icon: Icons.pending_actions_outlined, color: AppColors.warning,
                    onTap: () => context.go('/mse/selections')),
                  DashboardStatCard(
                    label: 'Approved Work', value: '${data['approvedSelections'] ?? 0}',
                    icon: Icons.check_circle_outline, color: AppColors.success,
                    onTap: () => context.go('/mse/selections')),
                  DashboardStatCard(
                    label: 'Completed', value: '${data['completedSelections'] ?? 0}',
                    icon: Icons.done_all_rounded, color: AppColors.secondary,
                    onTap: () => context.go('/mse/selections')),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: () => context.go('/mse/orders'),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Browse Open Orders'),
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
