import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/mse/selections/mse_selections_controller.dart';
import '../../../models/order_model.dart';
import '../../../services/api_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_chip.dart';
import 'mse_orders_controller.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  bool _loading  = false;
  String? _error;
  bool _submitted = false;

  @override
  void dispose() { _qtyCtrl.dispose(); super.dispose(); }

  Future<void> _selectQuantity(OrderModel order) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService(ref.read(apiClientProvider))
          .submitSelection(order.id, int.parse(_qtyCtrl.text.trim()));
      ref.invalidate(mySelectionsProvider);
      setState(() => _submitted = true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));
    final fmt  = NumberFormat('#,##0.00');
    final fmt2 = NumberFormat('#,###');

    if (_submitted) {
      return Scaffold(
        body: SafeArea(
          child: Center(child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle_outline_rounded, size: 80, color: AppColors.success),
              const SizedBox(height: AppSpacing.lg),
              Text('Selection Submitted!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text('Your selection is now pending admin review. You will be notified once approved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65)), textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              AppButton(label: 'View My Selections', onPressed: () => context.go('/mse/selections')),
              const SizedBox(height: AppSpacing.md),
              AppButton.outlined(label: 'Browse More Orders', onPressed: () => context.go('/mse/orders')),
            ]),
          )),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: orderAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Order info card
            Container(
              width: double.infinity, padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color, borderRadius: AppRadius.lg,
                border: Border.all(color: cs.outline.withValues(alpha: 0.08))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(order.description,
                    style: Theme.of(context).textTheme.titleMedium)),
                  StatusChip(status: order.status),
                ]),
                const Divider(height: 24),
                _DetailRow('Total Quantity', '${fmt2.format(order.totalQuantity)} units'),
                _DetailRow('Price Per Unit', '₹${fmt.format(order.pricePerUnit)}'),
                _DetailRow('Total Value',    '₹${fmt.format(order.totalValue)}'),
                _DetailRow('Deadline',       DateFormat('dd MMM yyyy').format(order.deadline),
                  color: order.isExpired ? AppColors.error : null),
                _DetailRow('Status',         order.status.toUpperCase()),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (!order.isAvailable) ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(color: AppColors.rejectedBg, borderRadius: AppRadius.md),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: AppColors.rejectedFg, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    order.isExpired ? 'This order has passed its deadline.' : 'This order is no longer accepting bids.',
                    style: const TextStyle(color: AppColors.rejectedFg, fontSize: 13))),
                ]),
              ),
            ] else ...[
              // Selection form
              Text('Submit Your Bid', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text('Enter the quantity you can supply (max ${fmt2.format(order.totalQuantity)} units)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: AppSpacing.md),

              if (_error != null)
                Container(width: double.infinity, margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: cs.errorContainer, borderRadius: AppRadius.md),
                  child: Text(_error!, style: TextStyle(color: cs.error, fontSize: 13))),

              Form(key: _formKey, child: TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Quantity (units)',
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  suffixText: '/ ${fmt2.format(order.totalQuantity)}',
                ),
                validator: (v) => Validators.quantity(v, max: order.totalQuantity),
              )),
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: 'Submit Bid', isLoading: _loading,
                onPressed: () => _selectQuantity(order), icon: Icons.send_outlined),
            ],
          ]),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final Color? color;
  const _DetailRow(this.label, this.value, {this.color});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: cs.onSurface.withValues(alpha: 0.6)))),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500, color: color))),
      ]),
    );
  }
}
