import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

// Stands in for `package:your_app/ix_icons.dart`, the file the generator
// writes into your app.
import 'generated_icons_stub.dart';

Widget internalKeyIcon() => const IxIcon.key(IxIconKey.home);

Widget catalogueIcon() => const IxIcon(IxIconsData.home);

Widget bothIconSources() => const Row(
  children: [
    IxIcon(IxIconsData.home), // explicit data (generated catalogue)
    IxIcon.key(IxIconKey.home), // resolver-driven (internal keys)
  ],
);

ThemeData themeWithCustomIcon() => IxThemeBuilder(
  icons: IxIconResolver.material().copyWith(
    icons: {IxIconKey.home: const IxIconData.asset('assets/custom/home.svg')},
  ),
).build();

// IxIconButton sizes its icon via a merged IconTheme — but IxIcon doesn't
// read IconTheme.size, so the button's slot and the icon's own `size:`
// must be set to match explicitly.
Widget closeButtonWithCatalogueIcon(VoidCallback onPressed) => IxIconButton(
  icon: const IxIcon(IxIconsData.close, size: IxIconSize.s16), // s24 → 16px
  size: IxIconButtonSize.s24,
  onPressed: onPressed,
);
