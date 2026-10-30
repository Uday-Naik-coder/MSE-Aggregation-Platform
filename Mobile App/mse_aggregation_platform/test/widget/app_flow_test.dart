import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mse_aggregation_platform/app/app.dart';
import 'package:mse_aggregation_platform/features/admin/dashboard/admin_dashboard_controller.dart';
import 'package:mse_aggregation_platform/features/auth/controllers/auth_controller.dart';
import 'package:mse_aggregation_platform/features/mse/dashboard/mse_dashboard_controller.dart';
import 'package:mse_aggregation_platform/models/user_model.dart';

class MockUnauthController extends AuthController {
  @override
  Future<UserModel?> build() async => null;
}

class MockAdminController extends AuthController {
  @override
  Future<UserModel?> build() async => UserModel(
    id: "admin1",
    email: "admin@test.com",
    name: "Admin User",
    role: "admin",
    isApproved: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

class MockPendingMseController extends AuthController {
  @override
  Future<UserModel?> build() async => UserModel(
    id: "mse1",
    email: "mse@test.com",
    name: "Pending MSE",
    role: "mse",
    isApproved: false,
    createdAt: DateTime(2026, 1, 1),
  );
}

class MockApprovedMseController extends AuthController {
  @override
  Future<UserModel?> build() async => UserModel(
    id: "mse2",
    email: "mse2@test.com",
    name: "Approved MSE",
    role: "mse",
    isApproved: true,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  testWidgets('Unauthenticated user is redirected to /login and navigates to /register', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(MockUnauthController.new),
        ],
        child: const App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sign in to MSE Aggregation Platform'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);

    final registerButton = find.byType(TextButton);
    expect(registerButton, findsOneWidget);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Business Name'), findsOneWidget);
    expect(find.byIcon(Icons.how_to_reg_outlined), findsOneWidget);
  });

  testWidgets('Pending MSE user is redirected to /pending-approval', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(MockPendingMseController.new),
        ],
        child: const App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Account Pending Approval'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });

  testWidgets('Admin user is redirected to /admin/dashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(MockAdminController.new),
          adminDashboardProvider.overrideWith((ref) async => {
            'totalOrders': 10,
            'openOrders': 4,
            'pendingSelections': 2,
            'pendingMSEs': 1,
            'completedSelections': 5,
          }),
        ],
        child: const App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('Good day, Admin User'), findsOneWidget);
  });

  testWidgets('Approved MSE user is redirected to /mse/dashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(MockApprovedMseController.new),
          mseDashboardProvider.overrideWith((ref) async => {
            'availableOrders': 4,
            'pendingSelections': 1,
            'approvedSelections': 2,
            'completedSelections': 3,
            'avgRating': 4.5,
          }),
        ],
        child: const App(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('My Dashboard'), findsOneWidget);
    expect(find.text('Welcome, Approved MSE'), findsOneWidget);
  });
}
