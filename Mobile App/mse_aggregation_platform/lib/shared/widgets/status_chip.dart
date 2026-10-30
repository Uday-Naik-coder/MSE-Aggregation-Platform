import 'package:flutter/material.dart';
import '../../app/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _resolve(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.full),
      child: Text(label, style: TextStyle(
        color: fg, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4,
      )),
    );
  }

  static (Color, Color, String) _resolve(String s) {
    switch (s.toLowerCase()) {
      case 'pending':     return (AppColors.pendingBg,   AppColors.pendingFg,   'PENDING');
      case 'approved':    return (AppColors.approvedBg,  AppColors.approvedFg,  'APPROVED');
      case 'rejected':    return (AppColors.rejectedBg,  AppColors.rejectedFg,  'REJECTED');
      case 'completed':   return (AppColors.completedBg, AppColors.completedFg, 'COMPLETED');
      case 'open':        return (AppColors.openBg,      AppColors.openFg,      'OPEN');
      case 'allocating':  return (AppColors.pendingBg,   AppColors.pendingFg,   'ALLOCATING');
      case 'closed':      return (AppColors.rejectedBg,  AppColors.rejectedFg,  'CLOSED');
      default:            return (AppColors.pendingBg,   AppColors.pendingFg,   s.toUpperCase());
    }
  }
}
