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

// IxIconButton sizes its icon via a merged IconTheme, which IxIcon reads:
// an IxIconButtonSize.s24 button renders its icon at 16px on its own. Pass
// `size:` only to override that.
Widget closeButtonWithCatalogueIcon(VoidCallback onPressed) => IxIconButton(
  icon: const IxIcon(IxIconsData.close), // 16px, from the button's slot
  size: IxIconButtonSize.s24,
  onPressed: onPressed,
);
