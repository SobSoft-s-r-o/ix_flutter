import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

Widget basicBreadcrumb() => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: 'home',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(label: 'Products', breadcrumbKey: 'products'),
    IxBreadcrumbItemData(label: 'Electronics', breadcrumbKey: 'electronics'),
    IxBreadcrumbItemData(label: 'Laptops', breadcrumbKey: 'laptops'),
  ],
  onItemClick: (click) {
    // Navigate to the selected level
    debugPrint('Navigate to: ${click.breadcrumbKey}');
  },
);

const manufacturingLevel = IxBreadcrumbItemData(
  label: 'Manufacturing', // Required: display text
  breadcrumbKey: 'manufacturing', // Recommended: stable identifier
  icon: IxIcon.key(IxIconKey.apps), // Optional: leading icon
);

Widget breadcrumbWithNextItems() => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: 'home',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(label: 'Settings', breadcrumbKey: 'settings'),
  ],
  nextItems: const [
    IxBreadcrumbMenuItem(label: 'General', breadcrumbKey: 'general'),
    IxBreadcrumbMenuItem(label: 'Privacy', breadcrumbKey: 'privacy'),
    IxBreadcrumbMenuItem(label: 'Security', breadcrumbKey: 'security'),
  ],
  onNextClick: (click) {
    // Navigate to child page
    debugPrint('Navigate to: ${click.breadcrumbKey}');
  },
);

Widget tertiaryBreadcrumb(List<IxBreadcrumbItemData> items) => IxBreadcrumb(
  items: items,
  buttonAppearance: IxBreadcrumbButtonAppearance.tertiary,
);

Widget subtlePrimaryBreadcrumb(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      buttonAppearance: IxBreadcrumbButtonAppearance.subtlePrimary,
    );

Widget breadcrumbWithVisibleItemCount(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      visibleItemCount: 4, // Show up to 4 items, collapse rest
    );

Widget breadcrumbWithCustomHomeIcon(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(items: items, homeIcon: const Icon(Icons.dashboard));

Widget breadcrumbWithHomeLabel(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      showHomeLabel: true, // Shows the label text next to home icon
    );

Widget breadcrumbWithoutNavigationMenu(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      showNavigationMenu: false, // Home button won't show dropdown
    );

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.onNavigate});

  /// Wire this to your router, e.g. `context.go` from `go_router`.
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          IxBreadcrumb(
            items: const [
              IxBreadcrumbItemData(
                label: 'Home',
                breadcrumbKey: '/',
                icon: IxIcon.key(IxIconKey.home),
              ),
              IxBreadcrumbItemData(
                label: 'Products',
                breadcrumbKey: '/products',
              ),
              IxBreadcrumbItemData(
                label: 'Widget Pro',
                breadcrumbKey: '/products/widget-pro',
              ),
            ],
            onItemClick: (click) => onNavigate(click.breadcrumbKey),
          ),
          // Page content
        ],
      ),
    );
  }
}

Widget deepBreadcrumb(ValueChanged<String> navigateToLevel) => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: 'home',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(
      label: 'Manufacturing',
      breadcrumbKey: 'manufacturing',
    ),
    IxBreadcrumbItemData(label: 'Production Lines', breadcrumbKey: 'lines'),
    IxBreadcrumbItemData(label: 'Line 04', breadcrumbKey: 'line-04'),
    IxBreadcrumbItemData(label: 'Station A', breadcrumbKey: 'station-a'),
    IxBreadcrumbItemData(label: 'Inspection', breadcrumbKey: 'inspection'),
  ],
  visibleItemCount: 3, // Only show 3 items, rest in overflow
  buttonAppearance: IxBreadcrumbButtonAppearance.subtlePrimary,
  onItemClick: (click) => navigateToLevel(click.breadcrumbKey),
);

Widget breadcrumbWithChildNavigation({
  required ValueChanged<String> goBack,
  required ValueChanged<String> navigateForward,
}) => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(
      label: 'Home',
      breadcrumbKey: 'home',
      icon: IxIcon.key(IxIconKey.home),
    ),
    IxBreadcrumbItemData(label: 'Settings', breadcrumbKey: 'settings'),
  ],
  nextItems: const [
    IxBreadcrumbMenuItem(label: 'Account', breadcrumbKey: 'account'),
    IxBreadcrumbMenuItem(label: 'Privacy', breadcrumbKey: 'privacy'),
    IxBreadcrumbMenuItem(
      label: 'Notifications',
      breadcrumbKey: 'notifications',
    ),
    IxBreadcrumbMenuItem(label: 'Display', breadcrumbKey: 'display'),
  ],
  onItemClick: (click) => goBack(click.breadcrumbKey),
  onNextClick: (click) => navigateForward(click.breadcrumbKey),
);

Widget responsiveBreadcrumb(List<IxBreadcrumbItemData> breadcrumbPath) =>
    LayoutBuilder(
      builder: (context, constraints) {
        final visibleCount = constraints.maxWidth < 600 ? 2 : 4;
        return IxBreadcrumb(
          items: breadcrumbPath,
          visibleItemCount: visibleCount,
          showHomeLabel: constraints.maxWidth > 800,
        );
      },
    );

class AppBreadcrumb extends StatelessWidget {
  const AppBreadcrumb({super.key, required this.currentPath, required this.go});

  final String currentPath;

  /// Wire this to `context.go` from `go_router` (or your router's equivalent).
  final ValueChanged<String> go;

  @override
  Widget build(BuildContext context) {
    return IxBreadcrumb(
      items: _buildBreadcrumbsFromPath(currentPath),
      onItemClick: (click) => go(click.breadcrumbKey),
    );
  }

  List<IxBreadcrumbItemData> _buildBreadcrumbsFromPath(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    var route = '';
    return [
      const IxBreadcrumbItemData(
        label: 'Home',
        breadcrumbKey: '/',
        icon: IxIcon.key(IxIconKey.home),
      ),
      ...segments.map((segment) {
        route = '$route/$segment';
        return IxBreadcrumbItemData(
          label: _formatLabel(segment),
          breadcrumbKey: route,
        );
      }),
    ];
  }

  String _formatLabel(String segment) => segment
      .replaceAll('-', ' ')
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

Widget breadcrumbWithStableKeys(ValueChanged<String> go) => IxBreadcrumb(
  items: const [
    IxBreadcrumbItemData(label: 'Reports', breadcrumbKey: 'reports-2024'),
    IxBreadcrumbItemData(label: 'Reports', breadcrumbKey: 'reports-2025'),
  ],
  onItemClick: (click) {
    // click.breadcrumbKey is 'reports-2024' or 'reports-2025', never
    // ambiguous even though both items render as "Reports".
    go('/reports/${click.breadcrumbKey}');
  },
);

Widget localizedBreadcrumb(List<IxBreadcrumbItemData> items) => IxBreadcrumb(
  items: items,
  strings: const IxBreadcrumbStrings(
    breadcrumbs: 'Navigation de fil d\'Ariane',
    previousItems: 'Afficher les éléments précédents',
    currentPage: 'page actuelle',
  ),
);

ThemeData withBreadcrumbOverrides(ThemeData base) {
  final breadcrumb = base.extension<IxBreadcrumbTheme>();
  if (breadcrumb == null) return base; // not an IxThemeBuilder theme
  return base.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ...base.extensions.values,
      breadcrumb.copyWith(
        height: 40,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4),
        itemSpacing: 8,
        maxItemWidth: 240,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.blue),
        currentItemStyle: const TextStyle(fontSize: 14, color: Colors.grey),
        separatorColor: Colors.grey,
        iconColor: Colors.blue,
        ellipsisFontWeight: FontWeight.w700,
        focusOutlineColor: Colors.blue,
      ),
    ],
  );
}

Widget breadcrumbWithSemanticLabels(List<IxBreadcrumbItemData> items) =>
    IxBreadcrumb(
      items: items,
      semanticLabel: 'Page navigation breadcrumb',
      previousItemsLabel: 'Earlier pages',
      homeMenuLabel: 'Jump to page',
      strings: const IxBreadcrumbStrings(currentPage: 'you are here'),
    );
