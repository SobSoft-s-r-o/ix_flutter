import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';

import 'screen/buttons_page.dart';
import 'screen/cards_page.dart';
import 'screen/badges_page.dart';
import 'screen/forms_page.dart';
import 'screen/home_page.dart';
import 'screen/modals_page.dart';
import 'screen/navigation_examples_page.dart';
import 'screen/spinner_page.dart';
import 'screen/slider_page.dart';
import 'screen/tabs_page.dart';
import 'edge_to_edge.dart';
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
            GoRoute(
              path: CardsPage.routePath,
              name: CardsPage.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const CardsPage(),
              ),
            ),
            GoRoute(
              path: BadgesPage.routePath,
              name: BadgesPage.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const BadgesPage(),
              ),
            ),
            GoRoute(
              path: TabsPage.routePath,
              name: TabsPage.routeName,
              pageBuilder: (context, state) =>
                  NoTransitionPage(key: state.pageKey, child: const TabsPage()),
            ),
            GoRoute(
              path: NavigationExamplesPage.routePath,
              name: NavigationExamplesPage.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const NavigationExamplesPage(),
              ),
            ),
            GoRoute(
              path: SliderPage.routePath,
              name: SliderPage.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const SliderPage(),
              ),
            ),
            GoRoute(
              path: SpinnerPage.routePath,
              name: SpinnerPage.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const SpinnerPage(),
              ),
            ),
            GoRoute(
              path: FormsPage.routePath,
              name: FormsPage.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const FormsPage(),
              ),
            ),
            GoRoute(
              path: ModalsPage.routePath,
              name: ModalsPage.routeName,
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const ModalsPage(),
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
            builder: (context, child) {
              final overlayStyle = EdgeToEdge.overlayStyleFor(
                Theme.of(context),
              );
              SystemChrome.setSystemUIOverlayStyle(overlayStyle);
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: child ?? const SizedBox.shrink(),
              );
            },
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
    final overlayStyle = EdgeToEdge.overlayStyleFor(Theme.of(context));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        key: _scaffoldKey,
        extendBody: true,
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
                      'Navigate between the overview plus the button, card, tabs, and form showcases.',
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
  _NavDestination(
    path: CardsPage.routePath,
    label: 'Cards',
    iconBuilder: () => IxIcons.dashboard,
    selectedIconBuilder: () => IxIcons.dashboardFilled,
  ),
  _NavDestination(
    path: BadgesPage.routePath,
    label: 'Badges & banners',
    iconBuilder: () => IxIcons.notification,
    selectedIconBuilder: () => IxIcons.notificationFilled,
  ),
  _NavDestination(
    path: TabsPage.routePath,
    label: 'Tabs',
    iconBuilder: () => IxIcons.layers,
    selectedIconBuilder: () => IxIcons.layersFilled,
  ),
  _NavDestination(
    path: NavigationExamplesPage.routePath,
    label: 'Navigation',
    iconBuilder: () => IxIcons.moreMenu,
    selectedIconBuilder: () => IxIcons.moreMenu,
  ),
  _NavDestination(
    path: SliderPage.routePath,
    label: 'Sliders',
    iconBuilder: () => IxIcons.controlSlider,
    selectedIconBuilder: () => IxIcons.switchSlider,
  ),
  _NavDestination(
    path: SpinnerPage.routePath,
    label: 'Spinners',
    iconBuilder: () => IxIcons.controlSpinner,
    selectedIconBuilder: () => IxIcons.controlSpinner,
  ),
  _NavDestination(
    path: FormsPage.routePath,
    label: 'Form inputs',
    iconBuilder: () => IxIcons.documentInfo,
    selectedIconBuilder: () => IxIcons.documentInfo,
  ),
  _NavDestination(
    path: ModalsPage.routePath,
    label: 'Modals',
    iconBuilder: () => IxIcons.info,
    selectedIconBuilder: () => IxIcons.infoFilled,
  ),
];
