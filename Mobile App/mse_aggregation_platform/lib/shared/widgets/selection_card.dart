import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/selection_model.dart';
import 'status_chip.dart';

class SelectionCard extends StatelessWidget {
  final SelectionModel selection;
  final Widget? actions;

  const SelectionCard({super.key, required this.selection, this.actions});

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final fmt = NumberFormat('#,###');
    final order = selection.order;
    final mse   = selection.mse;

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
          Expanded(child: Text(
            order?.description ?? 'Order #${selection.orderId.substring(0, 8)}',
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2, overflow: TextOverflow.ellipsis,
          )),
          const SizedBox(width: 8),
          StatusChip(status: selection.status),
        ]),
        if (mse != null) ...[
          const SizedBox(height: 6),
          Text(mse.businessName ?? mse.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
        ],
        const SizedBox(height: AppSpacing.sm),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Icon(Icons.inventory_2_outlined, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 4),
          Text('${fmt.format(selection.selectedQuantity)} units',
            style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: AppSpacing.md),
          if (order != null) ...[
            Icon(Icons.currency_rupee_outlined, size: 14, color: cs.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(NumberFormat('#,##0.00').format(selection.selectedQuantity * order.pricePerUnit),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ]),
        if (selection.adminApprovedAt != null) ...[
          const SizedBox(height: 4),
          Text('Approved: ${DateFormat('dd MMM yyyy').format(selection.adminApprovedAt!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.approvedFg)),
        ],
        if (selection.completedAt != null) ...[
          const SizedBox(height: 4),
          Text('Completed: ${DateFormat('dd MMM yyyy').format(selection.completedAt!)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.completedFg)),
        ],
        if (actions != null) ...[const SizedBox(height: AppSpacing.md), actions!],
      ]),
    );
  }
}
