import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/breakpoints.dart';
import '../state/auth_notifier.dart';

class NavItem {
  final IconData icon;
  final String label;
  final String path;
  final List<String> roles;
  const NavItem({required this.icon, required this.label, required this.path, this.roles = const []});
}

const _allNav = [
  NavItem(icon: Icons.storefront, label: 'Каталог', path: '/catalog'),
  NavItem(icon: Icons.person, label: 'Профиль', path: '/profile'),
  NavItem(icon: Icons.inventory_2, label: 'Товары', path: '/manager/products', roles: ['manager', 'admin']),
  NavItem(icon: Icons.receipt_long, label: 'Заказы', path: '/manager/orders', roles: ['manager', 'admin']),
  NavItem(icon: Icons.people, label: 'Пользователи', path: '/admin/users', roles: ['admin']),
];

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String currentPath;
  const AppScaffold({super.key, required this.child, required this.currentPath});

  List<NavItem> _visibleItems(AuthNotifier auth) =>
      _allNav.where((n) => n.roles.isEmpty || n.roles.contains(auth.role)).toList();

  int _selectedIndex(List<NavItem> items) {
    for (var i = 0; i < items.length; i++) {
      if (currentPath.startsWith(items[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final items = _visibleItems(auth);
    final index = _selectedIndex(items);
    final size = screenSizeOf(context);

    final appBar = AppBar(
      title: Text(items[index].label),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(child: Text('${auth.userName} (${auth.role})')),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Выйти',
          onPressed: () {
            context.read<AuthNotifier>().logout();
            context.go('/login');
          },
        ),
      ],
    );

    if (size == ScreenSize.compact) {
      return Scaffold(
        appBar: appBar,
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => context.go(items[i].path),
          destinations: [
            for (final n in items)
              NavigationDestination(icon: Icon(n.icon), label: n.label),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (i) => context.go(items[i].path),
            extended: size == ScreenSize.expanded,
            labelType: size == ScreenSize.expanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            destinations: [
              for (final n in items)
                NavigationRailDestination(icon: Icon(n.icon), label: Text(n.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}