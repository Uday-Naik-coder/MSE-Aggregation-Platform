import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../controllers/auth_controller.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hourglass_top_rounded, size: 64, color: AppColors.warning),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Account Pending Approval',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Your registration has been submitted successfully. An administrator will review and approve your account shortly.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.65)),
                textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: AppRadius.lg),
                child: const Column(children: [
                  _Step(number: '1', text: 'Registration submitted', done: true),
                  _Step(number: '2', text: 'Admin reviews your details', done: false),
                  _Step(number: '3', text: 'Account approved — you can log in', done: false),
                ]),
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  final bool done;
  const _Step({required this.number, required this.text, required this.done});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: done ? AppColors.success : cs.outline.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(child: done
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : Text(number, style: Theme.of(context).textTheme.labelSmall)),
        ),
        const SizedBox(width: 12),
        Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: done ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5))),
      ]),
    );
  }
}

