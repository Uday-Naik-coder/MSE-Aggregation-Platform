import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../models/selection_model.dart';
import '../../../services/api_service.dart';
import '../../../shared/components/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/selection_card.dart';
import 'admin_selections_controller.dart';

class PendingSelectionsScreen extends ConsumerWidget {
  const PendingSelectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selections = ref.watch(pendingSelectionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Selections')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(pendingSelectionsProvider.future),
        child: selections.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(pendingSelectionsProvider.future)),
          data: (list) => list.isEmpty
              ? const EmptyState(message: 'No pending selections.',
                  subtitle: 'All selections have been reviewed.',
                  icon: Icons.checklist_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _PendingCard(selection: list[i])),
        ),
      ),
    );
  }
}

class _PendingCard extends ConsumerStatefulWidget {
  final SelectionModel selection;
  const _PendingCard({required this.selection});
  @override
  ConsumerState<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends ConsumerState<_PendingCard> {
  bool _loading = false;

  Future<void> _approve() async {
    final ok = await ConfirmDialog.show(context,
      title: 'Approve Selection',
      message: 'Approve this selection of ${widget.selection.selectedQuantity} units?');
    if (!ok) return;
    setState(() => _loading = true);
    try {
      await ApiService(ref.read(apiClientProvider)).approveSelection(widget.selection.id);
      ref.invalidate(pendingSelectionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selection approved!')));
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

  Future<void> _reject() async {
    final ok = await ConfirmDialog.show(context,
      title: 'Reject Selection',
      message: 'Reject this selection? The MSE will not be able to complete this order.',
      confirmLabel: 'Reject', isDanger: true);
    if (!ok) return;
    setState(() => _loading = true);
    try {
      await ApiService(ref.read(apiClientProvider)).rejectSelection(widget.selection.id);
      ref.invalidate(pendingSelectionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selection rejected.')));
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
    return SelectionCard(
      selection: widget.selection,
      actions: _loading
        ? const Center(child: CircularProgressIndicator())
        : Row(children: [
            Expanded(child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white,
                minimumSize: const Size(0, 42)),
              onPressed: _approve,
              icon: const Icon(Icons.check_rounded, size: 16),
              label: const Text('Approve'),
            )),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error), minimumSize: const Size(0, 42)),
              onPressed: _reject,
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Reject'),
            )),
          ]),
    );
  }
}
