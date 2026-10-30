import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/order_model.dart';
import 'status_chip.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final Widget? trailing;

  const OrderCard({super.key, required this.order, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = NumberFormat('#,##0.00');
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Expanded(child: Text(order.description,
              style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            StatusChip(status: order.status),
          ]),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            _InfoItem(icon: Icons.inventory_2_outlined, label: '${NumberFormat('#,###').format(order.totalQuantity)} units'),
            const SizedBox(width: AppSpacing.md),
            _InfoItem(icon: Icons.currency_rupee_outlined, label: '${fmt.format(order.pricePerUnit)}/unit'),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            _InfoItem(
              icon: Icons.calendar_today_outlined,
              label: DateFormat('dd MMM yyyy').format(order.deadline),
              color: order.isExpired ? AppColors.error : null,
            ),
            const SizedBox(width: AppSpacing.md),
            if (!order.isExpired)
              _InfoItem(icon: Icons.timer_outlined,
                label: AppDateTimeHelper.timeRemaining(order.deadline),
                color: AppColors.warning),
          ]),
          if (trailing != null) ...[const SizedBox(height: AppSpacing.md), trailing!],
        ]),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c  = color ?? cs.onSurface.withValues(alpha: 0.6);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: c),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c)),
    ]);
  }
}

class AppDateTimeHelper {
  static String timeRemaining(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }
}
