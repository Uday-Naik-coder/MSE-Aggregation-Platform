import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.primary,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Logo mark
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: AppRadius.xl,
            ),
            child: const Icon(Icons.hub_rounded, size: 52, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('MSE Aggregation', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Text('Platform', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white, fontWeight: FontWeight.w300)),
          const SizedBox(height: AppSpacing.sm),
          Text('Connecting Orders with MSEs', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: 32, height: 32,
            child: CircularProgressIndicator(
              color: Colors.white.withValues(alpha: 0.8), strokeWidth: 2.5)),
        ]),
      ),
    );
  }
}
