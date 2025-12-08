import 'package:go_router/go_router.dart';

import '../screen/application_page.dart';
import '../screen/buttons_page.dart';
import '../screen/cards_page.dart';
import '../screen/blind_page.dart';
import '../screen/badges_page.dart';
import '../screen/dropdown_button_page.dart';
import '../screen/forms_page.dart';
import '../screen/home_page.dart';
import '../screen/modals_page.dart';
import '../screen/navigation_examples_page.dart';
import '../screen/spinner_page.dart';
import '../screen/slider_page.dart';
import '../screen/tabs_page.dart';
import '../screen/toast_page.dart';
import 'global_scaffold.dart';

final GoRouter router = GoRouter(
  initialLocation: HomePage.routePath,
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          GlobalScaffold(navigationState: state, child: child),
      routes: [
        GoRoute(
          path: HomePage.routePath,
          name: HomePage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const HomePage()),
        ),
        GoRoute(
          path: ToastPage.routePath,
          name: ToastPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const ToastPage()),
        ),
        GoRoute(
          path: ButtonsPage.routePath,
          name: ButtonsPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const ButtonsPage()),
        ),
        GoRoute(
          path: CardsPage.routePath,
          name: CardsPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const CardsPage()),
        ),
        GoRoute(
          path: BlindPage.routePath,
          name: BlindPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const BlindPage()),
        ),
        GoRoute(
          path: BadgesPage.routePath,
          name: BadgesPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const BadgesPage()),
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
          path: ApplicationPage.routePath,
          name: ApplicationPage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const ApplicationPage(),
          ),
        ),
        GoRoute(
          path: SliderPage.routePath,
          name: SliderPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const SliderPage()),
        ),
        GoRoute(
          path: SpinnerPage.routePath,
          name: SpinnerPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const SpinnerPage()),
        ),
        GoRoute(
          path: DropdownButtonPage.routePath,
          name: DropdownButtonPage.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const DropdownButtonPage(),
          ),
        ),
        GoRoute(
          path: FormsPage.routePath,
          name: FormsPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const FormsPage()),
        ),
        GoRoute(
          path: ModalsPage.routePath,
          name: ModalsPage.routeName,
          pageBuilder: (context, state) =>
              NoTransitionPage(key: state.pageKey, child: const ModalsPage()),
        ),
      ],
    ),
  ],
  debugLogDiagnostics: false,
);
