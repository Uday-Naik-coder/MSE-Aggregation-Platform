import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../shared/components/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import 'mse_approvals_controller.dart';

class MseApprovalsScreen extends ConsumerWidget {
  const MseApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mses = ref.watch(pendingMsesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pending MSE Approvals')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(pendingMsesProvider.future),
        child: mses.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.refresh(pendingMsesProvider.future)),
          data: (list) => list.isEmpty
              ? const EmptyState(message: 'All MSE registrations reviewed.',
                  subtitle: 'No pending approvals at this time.',
                  icon: Icons.people_outline)
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _MseCard(mse: list[i])),
        ),
      ),
    );
  }
}

class _MseCard extends ConsumerStatefulWidget {
  final UserModel mse;
  const _MseCard({required this.mse});
  @override
  ConsumerState<_MseCard> createState() => _MseCardState();
}

class _MseCardState extends ConsumerState<_MseCard> {
  bool _loading = false;

  Future<void> _approve() async {
    final ok = await ConfirmDialog.show(context,
      title: 'Approve MSE',
      message: 'Approve ${widget.mse.businessName ?? widget.mse.name}? They will be able to browse and select orders.');
    if (!ok) return;
    setState(() => _loading = true);
    try {
      await ApiService(ref.read(apiClientProvider)).approveMse(widget.mse.id);
      ref.invalidate(pendingMsesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MSE approved successfully!')));
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
    final cs = Theme.of(context).colorScheme;
    final mse = widget.mse;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: AppRadius.lg,
        border: Border.all(color: cs.outline.withValues(alpha: 0.08)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(mse.name[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(mse.businessName ?? mse.name, style: Theme.of(context).textTheme.titleSmall),
            Text(mse.name, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6))),
          ])),
        ]),
        const Divider(height: 24),
        _InfoRow(Icons.email_outlined,   mse.email),
        _InfoRow(Icons.badge_outlined,   mse.registrationId ?? '-'),
        _InfoRow(Icons.calendar_today_outlined,
          DateFormat('dd MMM yyyy').format(mse.createdAt)),
        const SizedBox(height: AppSpacing.md),
        SizedBox(width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
            onPressed: _loading ? null : _approve,
            icon: _loading ? const SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.check_rounded, size: 18),
            label: Text(_loading ? 'Approving...' : 'Approve Business'),
          )),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
      ]),
    );
  }
}
