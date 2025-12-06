import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siemens_ix_flutter/siemens_ix_flutter.dart';
import '../theme_controller.dart';

import '../screen/application_page.dart';
import '../screen/buttons_page.dart';
import '../screen/cards_page.dart';
import '../screen/blind_page.dart';
import '../screen/badges_page.dart';
import '../screen/forms_page.dart';
import '../screen/home_page.dart';
import '../screen/modals_page.dart';
import '../screen/navigation_examples_page.dart';
import '../screen/spinner_page.dart';
import '../screen/slider_page.dart';
import '../screen/tabs_page.dart';

class GlobalScaffold extends StatefulWidget {
  const GlobalScaffold({
    super.key,
    required this.navigationState,
    required this.child,
  });

  final GoRouterState navigationState;
  final Widget child;

  @override
  State<GlobalScaffold> createState() => _GlobalScaffoldState();
}

class _GlobalScaffoldState extends State<GlobalScaffold> {
  @override
  Widget build(BuildContext context) {
    final location = widget.navigationState.matchedLocation;

    String selectedId = _getIdFromLocation(location);

    return IxApplicationScaffold(
      appTitle: 'Siemens IX Flutter Demo',
      entries: _buildEntries(selectedId),
      onNavigate: (id) => _onNavigate(context, id),
      body: widget.child,
      themeMode: ThemeControllerScope.of(context).mode,
      onThemeModeChanged: (mode) {
        ThemeControllerScope.of(context).setMode(mode);
      },
      showSettings: false,
      showAboutLegal: false,
    );
  }

  String _getIdFromLocation(String location) {
    if (location == HomePage.routePath) return 'home';
    if (location == ButtonsPage.routePath) return 'buttons';
    if (location == CardsPage.routePath) return 'cards';
    if (location == BlindPage.routePath) return 'blind';
    if (location == BadgesPage.routePath) return 'badges';
    if (location == TabsPage.routePath) return 'tabs';
    if (location == NavigationExamplesPage.routePath) return 'navigation';
    if (location == ApplicationPage.routePath) return 'app_menu';
    if (location == SliderPage.routePath) return 'sliders';
    if (location == SpinnerPage.routePath) return 'spinners';
    if (location == FormsPage.routePath) return 'forms';
    if (location == ModalsPage.routePath) return 'modals';
    return 'home';
  }

  void _onNavigate(BuildContext context, String id) {
    switch (id) {
      case 'home':
        context.go(HomePage.routePath);
        break;
      case 'buttons':
        context.go(ButtonsPage.routePath);
        break;
      case 'cards':
        context.go(CardsPage.routePath);
        break;
      case 'blind':
        context.go(BlindPage.routePath);
        break;
      case 'badges':
        context.go(BadgesPage.routePath);
        break;
      case 'tabs':
        context.go(TabsPage.routePath);
        break;
      case 'navigation':
        context.go(NavigationExamplesPage.routePath);
        break;
      case 'app_menu':
        context.go(ApplicationPage.routePath);
        break;
      case 'sliders':
        context.go(SliderPage.routePath);
        break;
      case 'spinners':
        context.go(SpinnerPage.routePath);
        break;
      case 'forms':
        context.go(FormsPage.routePath);
        break;
      case 'modals':
        context.go(ModalsPage.routePath);
        break;
    }
  }

  List<IxMenuEntry> _buildEntries(String selectedId) {
    return [
      IxMenuEntry(
        id: 'home',
        type: IxMenuEntryType.item,
        label: 'Overview',
        iconWidget: IxIcons.home,
        selected: selectedId == 'home',
      ),
      IxMenuEntry(
        id: 'buttons',
        type: IxMenuEntryType.item,
        label: 'Buttons',
        iconWidget: IxIcons.controlButton,
        selected: selectedId == 'buttons',
      ),
      IxMenuEntry(
        id: 'cards',
        type: IxMenuEntryType.item,
        label: 'Cards',
        iconWidget: IxIcons.dashboard,
        selected: selectedId == 'cards',
      ),
      IxMenuEntry(
        id: 'blind',
        type: IxMenuEntryType.item,
        label: 'Blind',
        iconWidget: IxIcons.chevronDown,
        selected: selectedId == 'blind',
      ),
      IxMenuEntry(
        id: 'badges',
        type: IxMenuEntryType.item,
        label: 'Badges & banners',
        iconWidget: IxIcons.notification,
        selected: selectedId == 'badges',
      ),
      IxMenuEntry(
        id: 'tabs',
        type: IxMenuEntryType.item,
        label: 'Tabs',
        iconWidget: IxIcons.layers,
        selected: selectedId == 'tabs',
      ),
      IxMenuEntry(
        id: 'navigation',
        type: IxMenuEntryType.item,
        label: 'Navigation',
        iconWidget: IxIcons.moreMenu,
        selected: selectedId == 'navigation',
      ),
      IxMenuEntry(
        id: 'app_menu',
        type: IxMenuEntryType.item,
        label: 'App menu',
        iconWidget: IxIcons.appMenu,
        selected: selectedId == 'app_menu',
      ),
      IxMenuEntry(
        id: 'sliders',
        type: IxMenuEntryType.item,
        label: 'Sliders',
        iconWidget: IxIcons.controlSlider,
        selected: selectedId == 'sliders',
      ),
      IxMenuEntry(
        id: 'spinners',
        type: IxMenuEntryType.item,
        label: 'Spinners',
        iconWidget: IxIcons.controlSpinner,
        selected: selectedId == 'spinners',
      ),
      IxMenuEntry(
        id: 'forms',
        type: IxMenuEntryType.item,
        label: 'Form inputs',
        iconWidget: IxIcons.documentInfo,
        selected: selectedId == 'forms',
      ),
      IxMenuEntry(
        id: 'modals',
        type: IxMenuEntryType.item,
        label: 'Modals',
        iconWidget: IxIcons.info,
        selected: selectedId == 'modals',
      ),
      IxMenuEntry(
        id: 'theme-toggle',
        type: IxMenuEntryType.custom,
        icon: Icons.brightness_6_outlined,
        label: 'Theme',
        tooltip: 'Switch between light, dark, and system',
        isBottom: true,
      ),
    ];
  }
}
