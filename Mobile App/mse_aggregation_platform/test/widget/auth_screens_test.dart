import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mse_aggregation_platform/features/auth/screens/login_screen.dart';
import 'package:mse_aggregation_platform/features/auth/screens/pending_approval_screen.dart';
import 'package:mse_aggregation_platform/app/theme.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('renders all expected form fields and buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const LoginScreen(),
          ),
        ),
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to MSE Aggregation Platform'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('validates required email and password fields on submit', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const LoginScreen(),
          ),
        ),
      );

      // Tap Sign In without typing anything
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('validates email format', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const LoginScreen(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'notanemail');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });
  });

  group('PendingApprovalScreen Widget Tests', () {
    testWidgets('renders pending message, approval steps and logout button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PendingApprovalScreen(),
          ),
        ),
      );

      expect(find.text('Account Pending Approval'), findsOneWidget);
      expect(find.text('Registration submitted'), findsOneWidget);
      expect(find.text('Admin reviews your details'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
    });
  });
}

