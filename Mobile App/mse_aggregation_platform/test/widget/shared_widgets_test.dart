import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mse_aggregation_platform/shared/widgets/status_chip.dart';
import 'package:mse_aggregation_platform/shared/widgets/empty_state.dart';
import 'package:mse_aggregation_platform/shared/widgets/app_button.dart';
import 'package:mse_aggregation_platform/app/theme.dart';

void main() {
  group('StatusChip', () {
    testWidgets('displays correct label for approved', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'approved'),
          ),
        ),
      );
      expect(find.text('APPROVED'), findsOneWidget);
    });

    testWidgets('displays correct label for pending', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'pending'),
          ),
        ),
      );
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('displays correct label for completed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(status: 'completed'),
          ),
        ),
      );
      expect(find.text('COMPLETED'), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('displays title, subtitle, and action button', (tester) async {
      bool actionTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EmptyState(
              message: 'No Orders Available',
              subtitle: 'Check back later for new supply orders.',
              actionLabel: 'Refresh',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No Orders Available'), findsOneWidget);
      expect(find.text('Check back later for new supply orders.'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      await tester.pump();
      expect(actionTapped, isTrue);
    });
  });

  group('AppButton', () {
    testWidgets('renders label and triggers callback on press', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Submit Selection',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit Selection'), findsOneWidget);
      await tester.tap(find.text('Submit Selection'));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('renders progress indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Submit Selection',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Selection'), findsNothing);
    });
  });
}

