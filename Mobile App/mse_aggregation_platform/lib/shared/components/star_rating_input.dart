import 'package:flutter/material.dart';
import '../../app/theme.dart';

class StarRatingInput extends StatefulWidget {
  final String label;
  final int initialRating;
  final void Function(int) onChanged;
  final bool required;

  const StarRatingInput({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialRating = 0,
    this.required = true,
  });

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelMedium),
        if (widget.required) Text(' *', style: TextStyle(color: cs.error)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        ...List.generate(5, (i) {
          final filled = i < _rating;
          return GestureDetector(
            onTap: () { setState(() => _rating = i + 1); widget.onChanged(_rating); },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                key: ValueKey(filled),
                size: 36,
                color: filled ? AppColors.starFilled : cs.onSurface.withValues(alpha: 0.3),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(_ratingLabel(_rating),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.6), fontStyle: FontStyle.italic)),
      ]),
    ]);
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Very Poor';
      case 2: return 'Below Average';
      case 3: return 'Average';
      case 4: return 'Good';
      case 5: return 'Excellent';
      default: return 'Tap to rate';
    }
  }
}
