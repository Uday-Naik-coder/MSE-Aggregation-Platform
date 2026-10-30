import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../models/selection_model.dart';
import '../../../services/api_service.dart';
import '../../../shared/components/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/selection_card.dart';
import 'mse_selections_controller.dart';

class MySelectionsScreen extends ConsumerWidget {
  const MySelectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(mySelectionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Selections')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/mse/orders'),
        icon: const Icon(Icons.add),
        label: const Text('Browse Orders'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(mySelectionsProvider.future),
        child: selections.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(mySelectionsProvider.future)),
          data: (list) => list.isEmpty
              ? EmptyState(message: "You haven't selected any orders yet.",
                  subtitle: 'Browse open orders and submit a bid.',
                  icon: Icons.receipt_long_outlined,
                  actionLabel: 'Browse Orders',
                  onAction: () => context.go('/mse/orders'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _SelectionWithAction(selection: list[i])),
        ),
      ),
    );
  }
}

class _SelectionWithAction extends ConsumerStatefulWidget {
  final SelectionModel selection;
  const _SelectionWithAction({required this.selection});
  @override
  ConsumerState<_SelectionWithAction> createState() => _SelectionWithActionState();
}

class _SelectionWithActionState extends ConsumerState<_SelectionWithAction> {
  bool _loading = false;

  Future<void> _markComplete() async {
    final ok = await ConfirmDialog.show(context,
      title: 'Mark as Completed',
      message: 'Confirm that you have completed this work? This cannot be undone.');
    if (!ok) return;
    setState(() => _loading = true);
    try {
      await ApiService(ref.read(apiClientProvider)).completeSelection(widget.selection.id);
      ref.invalidate(mySelectionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Work marked as completed!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selection;
    Widget? actionWidget;

    if (sel.isApproved) {
      actionWidget = _loading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success, foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 42)),
              onPressed: _markComplete,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Mark as Completed'),
            );
    } else if (sel.isPending) {
      actionWidget = Container(
        width: double.infinity, padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: AppColors.pendingBg, borderRadius: AppRadius.sm),
        child: const Row(children: [
          Icon(Icons.access_time_rounded, color: AppColors.pendingFg, size: 14),
          SizedBox(width: 6),
          Text('Awaiting admin approval', style: TextStyle(color: AppColors.pendingFg, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      );
    } else if (sel.isCompleted) {
      actionWidget = Container(
        width: double.infinity, padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: AppColors.completedBg, borderRadius: AppRadius.sm),
        child: const Row(children: [
          Icon(Icons.done_all_rounded, color: AppColors.completedFg, size: 14),
          SizedBox(width: 6),
          Text('Work completed', style: TextStyle(color: AppColors.completedFg, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      );
    } else if (sel.isRejected) {
      actionWidget = Container(
        width: double.infinity, padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(color: AppColors.rejectedBg, borderRadius: AppRadius.sm),
        child: const Row(children: [
          Icon(Icons.close_rounded, color: AppColors.rejectedFg, size: 14),
          SizedBox(width: 6),
          Text('Selection rejected', style: TextStyle(color: AppColors.rejectedFg, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      );
    }

    return SelectionCard(selection: sel, actions: actionWidget);
  }
}
