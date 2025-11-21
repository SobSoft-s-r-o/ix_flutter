import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

import 'screen/buttons_page.dart';
import 'screen/home_page.dart';
import 'theme_controller.dart';

class SiemensIxDemoApp extends StatefulWidget {
  const SiemensIxDemoApp({super.key});

  @override
  State<SiemensIxDemoApp> createState() => _SiemensIxDemoAppState();
}

class _SiemensIxDemoAppState extends State<SiemensIxDemoApp> {
  late final ThemeController _controller;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _controller = ThemeController();
    _router = GoRouter(
      initialLocation: HomePage.routePath,
      routes: [
        ShellRoute(
          builder: (context, state, child) =>
              DemoShell(navigationState: state, child: child),
          routes: [
            GoRoute(
              path: HomePage.routePath,
              name: HomePage.routeName,
              pageBuilder: (context, state) =>
                  NoTransitionPage(key: state.pageKey, child: const HomePage()),
            ),
            GoRoute(
              path: ButtonsPage.routePath,
              name: ButtonsPage.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const ButtonsPage(),
              ),
            ),
          ],
        ),
      ],
      debugLogDiagnostics: false,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ThemeControllerScope(
          controller: _controller,
          child: MaterialApp.router(
            title: 'Siemens IX Flutter Demo',
            routerConfig: _router,
            theme: _controller.buildTheme(ThemeMode.light),
            darkTheme: _controller.buildTheme(ThemeMode.dark),
            themeMode: _controller.mode,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}

class DemoShell extends StatefulWidget {
  const DemoShell({
    super.key,
    required this.navigationState,
    required this.child,
  });

  final GoRouterState navigationState;
  final Widget child;

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.sizeOf(context).width >= 960;
    final location = widget.navigationState.matchedLocation;
    final destinations = _navDestinations;
    final selectedIndex = destinations.indexWhere(
      (dest) => dest.matches(location),
    );
    final currentIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: isLargeScreen
            ? null
            : IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: IxIcons.appMenu,
              ),
        title: const Text('Siemens IX Flutter Demo'),
      ),
      drawer: isLargeScreen
          ? null
          : _NavigationDrawer(
              currentIndex: currentIndex,
              onSelect: (index) {
                Navigator.of(context).pop();
                _goTo(index);
              },
            ),
      body: Row(
        children: [
          if (isLargeScreen)
            _NavigationRail(currentIndex: currentIndex, onSelect: _goTo),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  void _goTo(int index) {
    final destination = _navDestinations[index];
    context.go(destination.path);
  }
}

class _NavigationRail extends StatelessWidget {
  const _NavigationRail({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelect,
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final dest in _navDestinations)
          NavigationRailDestination(
            icon: dest.iconBuilder(),
            selectedIcon: dest.selectedIconBuilder(),
            label: Text(dest.label),
          ),
      ],
    );
  }
}

class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView.builder(
          itemCount: _navDestinations.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              final theme = Theme.of(context).textTheme;
              return DrawerHeader(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pages', style: theme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Navigate between the overview and button showcase.',
                      style: theme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            final destination = _navDestinations[index - 1];
            final isSelected = currentIndex == index - 1;

            return ListTile(
              leading: destination.iconBuilder(),
              title: Text(destination.label),
              selected: isSelected,
              onTap: () => onSelect(index - 1),
            );
          },
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.path,
    required this.label,
    required this.iconBuilder,
    required this.selectedIconBuilder,
  });

  final String path;
  final String label;
  final Widget Function() iconBuilder;
  final Widget Function() selectedIconBuilder;

  bool matches(String? location) {
    if (location == null || location.isEmpty) {
      return path == HomePage.routePath;
    }
    if (path == HomePage.routePath) {
      return location == HomePage.routePath;
    }
    return location.startsWith(path);
  }
}

final List<_NavDestination> _navDestinations = [
  _NavDestination(
    path: HomePage.routePath,
    label: 'Overview',
    iconBuilder: () => IxIcons.home,
    selectedIconBuilder: () => IxIcons.homeFilled,
  ),
  _NavDestination(
    path: ButtonsPage.routePath,
    label: 'Buttons',
    iconBuilder: () => IxIcons.controlButton,
    selectedIconBuilder: () => IxIcons.controlTextButton,
  ),
];
