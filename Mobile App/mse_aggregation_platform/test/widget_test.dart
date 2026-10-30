import 'package:flutter_test/flutter_test.dart';
import 'package:mse_aggregation_platform/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    // Splash screen should be present on launch
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
