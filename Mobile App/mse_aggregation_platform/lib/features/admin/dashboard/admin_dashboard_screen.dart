import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../shared/components/confirm_dialog.dart';
import '../../../shared/widgets/dashboard_stat_card.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user  = ref.watch(authControllerProvider).valueOrNull;
    final stats = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Admin Dashboard', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text('Good day, ${user?.name ?? 'Admin'}',
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
        onRefresh: () => ref.refresh(adminDashboardProvider.future),
        child: stats.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(adminDashboardProvider.future)),
          data: (data) => _DashboardBody(data: data),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DashboardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Stats grid
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.25,
          children: [
            DashboardStatCard(
              label: 'Total Orders', value: '${data['totalOrders'] ?? 0}',
              icon: Icons.list_alt_outlined, color: AppColors.primary,
              onTap: () => context.go('/admin/orders')),
            DashboardStatCard(
              label: 'Open Orders', value: '${data['openOrders'] ?? 0}',
              icon: Icons.shopping_bag_outlined, color: AppColors.success,
              onTap: () => context.go('/admin/orders')),
            DashboardStatCard(
              label: 'Pending Selections', value: '${data['pendingSelections'] ?? 0}',
              icon: Icons.pending_actions_outlined, color: AppColors.warning,
              onTap: () => context.go('/admin/selections')),
            DashboardStatCard(
              label: 'Pending MSE Approvals', value: '${data['pendingMSEs'] ?? 0}',
              icon: Icons.people_outline, color: AppColors.info,
              onTap: () => context.go('/admin/mse-approvals')),
            DashboardStatCard(
              label: 'Completed', value: '${data['completedSelections'] ?? 0}',
              icon: Icons.check_circle_outline, color: AppColors.secondary,
              onTap: () => context.go('/admin/completed')),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Quick actions
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        _QuickAction(icon: Icons.add_circle_outline, label: 'Create New Order',
          subtitle: 'Post a new order for MSEs to bid on',
          color: AppColors.primary, onTap: () => context.go('/admin/orders/create')),
        _QuickAction(icon: Icons.checklist_rounded, label: 'Review Selections',
          subtitle: 'Approve or reject pending MSE bids',
          color: AppColors.warning, onTap: () => context.go('/admin/selections')),
        _QuickAction(icon: Icons.how_to_reg_outlined, label: 'Approve MSEs',
          subtitle: 'Review pending MSE registrations',
          color: AppColors.info, onTap: () => context.go('/admin/mse-approvals')),
        _QuickAction(icon: Icons.star_outline_rounded, label: 'Rate Completed Work',
          subtitle: 'View and rate completed selections',
          color: AppColors.secondary, onTap: () => context.go('/admin/completed')),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(onTap: onTap, borderRadius: AppRadius.lg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppRadius.md),
              child: Icon(icon, color: color, size: 22)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: Theme.of(context).textTheme.titleSmall),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6))),
            ])),
            Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.4)),
          ]),
        ),
      ),
    );
  }
}
