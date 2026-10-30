import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/pending_approval_screen.dart';

// Admin screens
import '../features/admin/dashboard/admin_dashboard_screen.dart';
import '../features/admin/orders/admin_orders_screen.dart';
import '../features/admin/orders/create_order_screen.dart';
import '../features/admin/mse_approvals/mse_approvals_screen.dart';
import '../features/admin/selections/pending_selections_screen.dart';
import '../features/admin/selections/completed_selections_screen.dart';
import '../features/admin/ratings/admin_ratings_screen.dart';
import '../features/admin/ratings/rate_mse_screen.dart';

// MSE screens
import '../features/mse/dashboard/mse_dashboard_screen.dart';
import '../features/mse/orders/open_orders_screen.dart';
import '../features/mse/orders/order_detail_screen.dart';
import '../features/mse/selections/my_selections_screen.dart';
import '../features/mse/ratings/mse_ratings_screen.dart';

import '../shared/components/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);

      // While loading, stay on splash
      if (authState.isLoading) return '/splash';

      final user = authState.valueOrNull;
      final loc  = state.matchedLocation;

      final isSplash = loc == '/splash';
      final isAuthScreen = loc == '/login' || loc == '/register' || loc == '/pending-approval';

      // 1. Not logged in
      if (user == null) {
        if (isSplash) return '/login';
        return isAuthScreen ? null : '/login';
      }

      // 2. Pending MSE
      if (user.isMse && !user.isApproved) {
        return loc == '/pending-approval' ? null : '/pending-approval';
      }

      // 3. Admin
      if (user.isAdmin) {
        if (isSplash || isAuthScreen || loc.startsWith('/mse')) {
          return '/admin/dashboard';
        }
        return null;
      }

      // 4. Approved MSE
      if (user.isMse && user.isApproved) {
        if (isSplash || isAuthScreen || loc.startsWith('/admin')) {
          return '/mse/dashboard';
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash',           builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',            builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',         builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/pending-approval', builder: (_, __) => const PendingApprovalScreen()),

      // Admin shell
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/dashboard',   builder: (_, __) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/orders',       builder: (_, __) => const AdminOrdersScreen()),
          GoRoute(path: '/admin/orders/create',builder: (_, __) => const CreateOrderScreen()),
          GoRoute(path: '/admin/mse-approvals',builder: (_, __) => const MseApprovalsScreen()),
          GoRoute(path: '/admin/selections',   builder: (_, __) => const PendingSelectionsScreen()),
          GoRoute(path: '/admin/completed',    builder: (_, __) => const CompletedSelectionsScreen()),
          GoRoute(path: '/admin/ratings',      builder: (_, __) => const AdminRatingsScreen()),
          GoRoute(
            path: '/admin/rate/:selectionId',
            builder: (_, state) => RateMseScreen(selectionId: state.pathParameters['selectionId']!),
          ),
        ],
      ),

      // MSE shell
      ShellRoute(
        builder: (context, state, child) => MseShell(child: child),
        routes: [
          GoRoute(path: '/mse/dashboard',   builder: (_, __) => const MseDashboardScreen()),
          GoRoute(path: '/mse/orders',       builder: (_, __) => const OpenOrdersScreen()),
          GoRoute(
            path: '/mse/orders/:id',
            builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/mse/selections',  builder: (_, __) => const MySelectionsScreen()),
          GoRoute(path: '/mse/ratings',      builder: (_, __) => const MseRatingsScreen()),
        ],
      ),
    ],
  );
});

// Triggers router refresh when auth state changes
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}



