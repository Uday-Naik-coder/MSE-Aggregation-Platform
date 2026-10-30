import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/admin/selections/admin_selections_controller.dart';
import '../../../models/selection_model.dart';
import '../../../services/api_service.dart';
import '../../../shared/components/star_rating_input.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import 'admin_ratings_controller.dart';

class RateMseScreen extends ConsumerStatefulWidget {
  final String selectionId;
  const RateMseScreen({super.key, required this.selectionId});
  @override
  ConsumerState<RateMseScreen> createState() => _RateMseScreenState();
}

class _RateMseScreenState extends ConsumerState<RateMseScreen> {
  int _timeliness = 0, _quality = 0, _communication = 0;
  final _commentCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _submit(SelectionModel sel) async {
    if (_timeliness == 0 || _quality == 0) {
      setState(() => _error = 'Please rate Timeliness and Quality (required).');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final body = {
        'selectionId':        sel.id,
        'timelinessScore':    _timeliness,
        'qualityScore':       _quality,
        if (_communication > 0) 'communicationScore': _communication,
        if (_commentCtrl.text.trim().isNotEmpty) 'comment': _commentCtrl.text.trim(),
      };
      await ApiService(ref.read(apiClientProvider)).submitRating(body);
      ref.invalidate(adminRatingsProvider);
      ref.invalidate(completedSelectionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully!')));
        context.go('/admin/completed');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectionsAsync = ref.watch(completedSelectionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rate MSE Performance')),
      body: selectionsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (list) {
          final sel = list.where((s) => s.id == widget.selectionId).firstOrNull;
          if (sel == null) return const ErrorState(message: 'Selection not found.');
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Order context card
              Container(
                width: double.infinity, padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.4), borderRadius: AppRadius.lg),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Reviewing work by:', style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 4),
                  Text(sel.mse?.businessName ?? sel.mse?.name ?? 'MSE',
                    style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Order: ${sel.order?.description ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text('Qty: ${sel.selectedQuantity} units',
                    style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_error != null)
                Container(width: double.infinity, margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: cs.errorContainer, borderRadius: AppRadius.md),
                  child: Text(_error!, style: TextStyle(color: cs.error, fontSize: 13))),

              StarRatingInput(label: 'Timeliness', onChanged: (v) => setState(() => _timeliness = v)),
              const SizedBox(height: AppSpacing.lg),
              StarRatingInput(label: 'Quality', onChanged: (v) => setState(() => _quality = v)),
              const SizedBox(height: AppSpacing.lg),
              StarRatingInput(label: 'Communication', required: false, onChanged: (v) => setState(() => _communication = v)),
              const SizedBox(height: AppSpacing.lg),

              Text('Comments (Optional)', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _commentCtrl, maxLines: 3,
                decoration: const InputDecoration(hintText: 'Share specific feedback about the MSE...'),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'Submit Rating', isLoading: _loading, onPressed: () => _submit(sel),
                icon: Icons.star_rounded),
            ]),
          );
        },
      ),
    );
  }
}
