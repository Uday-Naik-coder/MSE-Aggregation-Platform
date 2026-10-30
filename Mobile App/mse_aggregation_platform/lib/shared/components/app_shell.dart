import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Admin Shell ──────────────────────────────────────────────────────────────
class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.dashboard_outlined,    label: 'Dashboard', path: '/admin/dashboard'),
    (icon: Icons.list_alt_outlined,     label: 'Orders',    path: '/admin/orders'),
    (icon: Icons.people_outline,        label: 'MSEs',      path: '/admin/mse-approvals'),
    (icon: Icons.checklist_outlined,    label: 'Selections',path: '/admin/selections'),
    (icon: Icons.star_outline_rounded,  label: 'Ratings',   path: '/admin/ratings'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    int idx = _tabs.indexWhere((t) => loc.startsWith(t.path));
    if (idx < 0) idx = 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon), label: t.label,
        )).toList(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 3,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}

// ── MSE Shell ────────────────────────────────────────────────────────────────
class MseShell extends StatelessWidget {
  final Widget child;
  const MseShell({super.key, required this.child});

  static const _tabs = [
    (icon: Icons.dashboard_outlined,    label: 'Dashboard',  path: '/mse/dashboard'),
    (icon: Icons.shopping_bag_outlined, label: 'Orders',     path: '/mse/orders'),
    (icon: Icons.receipt_long_outlined, label: 'Selections', path: '/mse/selections'),
    (icon: Icons.star_outline_rounded,  label: 'Ratings',    path: '/mse/ratings'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    int idx = _tabs.indexWhere((t) => loc.startsWith(t.path));
    if (idx < 0) idx = 0;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].path),
        destinations: _tabs.map((t) => NavigationDestination(
          icon: Icon(t.icon), label: t.label,
        )).toList(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 3,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
    );
  }
}
