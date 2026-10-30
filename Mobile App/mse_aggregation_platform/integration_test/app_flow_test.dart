import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mse_aggregation_platform/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launch to login screen navigation test', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    // Initial splash
    await tester.pump();
    expect(find.byType(App), findsOneWidget);

    // Wait for splash auth check delay (1.2s)
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Should redirect to Login screen
    expect(find.text('Sign in to MSE Aggregation Platform'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    // Navigate to Register screen
    final registerLink = find.text('Register');
    if (registerLink.evaluate().isNotEmpty) {
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // Check register screen fields
      expect(find.text('Create an Account'), findsOneWidget);
      expect(find.text('Business Name'), findsOneWidget);
      expect(find.text('Registration ID'), findsOneWidget);
    }
  });
}

