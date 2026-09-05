import 'package:flutter/material.dart';
import 'package:ix_flutter/ix_flutter.dart';

Widget densityScopedApp() => MaterialApp(
  theme: const IxThemeBuilder().build(),
  builder: (context, child) =>
      IxDensityScope(child: child ?? const SizedBox.shrink()),
  home: const Placeholder(),
);

Widget compactSubtree(Widget toolbar) => IxDensityScope(
  density: IxDensity.compact, // e.g. a dense data-table toolbar
  child: toolbar,
);

Widget closeButton(VoidCallback onPressed) => IxIconButton(
  icon: const Icon(Icons.close),
  onPressed: onPressed,
  tooltip: 'Close',
);
