import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/rating_model.dart';

class RatingCard extends StatelessWidget {
  final RatingModel rating;
  const RatingCard({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
            rating.order?.description ?? 'Order',
            style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis,
          )),
          _StarDisplay(rating.overallRating),
        ]),
        const SizedBox(height: AppSpacing.sm),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        _ScoreRow('Timeliness',    rating.timelinessScore),
        _ScoreRow('Quality',       rating.qualityScore),
        if (rating.communicationScore != null)
          _ScoreRow('Communication', rating.communicationScore!),
        if (rating.comment != null && rating.comment!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('"${rating.comment}"',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic, color: cs.onSurface.withValues(alpha: 0.7))),
        ],
        const SizedBox(height: 6),
        Text(DateFormat('dd MMM yyyy').format(rating.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.45))),
      ]),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  const _ScoreRow(this.label, this.score);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(width: 110, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        ...List.generate(5, (i) => Icon(
          i < score ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16, color: i < score ? AppColors.starFilled : AppColors.starEmpty,
        )),
        const SizedBox(width: 4),
        Text('$score/5', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _StarDisplay extends StatelessWidget {
  final double rating;
  const _StarDisplay(this.rating);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.starFilled.withValues(alpha: 0.12), borderRadius: AppRadius.sm),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.starFilled),
        const SizedBox(width: 2),
        Text(rating.toStringAsFixed(1), style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.starFilled)),
      ]),
    );
  }
}
