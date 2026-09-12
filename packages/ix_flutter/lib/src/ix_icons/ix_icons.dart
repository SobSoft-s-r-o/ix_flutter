// INTERNAL PLACEHOLDER (deprecated; removed in 2.0)
//
// Library widgets resolve icons through IxIconResolver (see ix_icon_resolver.dart).
// Icons for apps are generated with: dart run ix_icons_generator:generate_icons
// License and upstream version: see UPSTREAM.md (@siemens/ix-icons is MIT).

import 'package:flutter/material.dart';

/// Placeholder IxIcons class.
///
/// This legacy stub remains for consumers that imported this source file.
/// Use IxIcon with IxIconKey for defaults, or generate app icons with
/// `dart run ix_icons_generator:generate_icons`.
///
/// These placeholders display Material Icons as fallbacks.
@Deprecated(
  'Use IxIcon with IxIconKey, or generated app icons. Removed in 2.0.',
)
class IxIcons {
  IxIcons._();

  // Navigation icons
  static Widget get home => const Icon(Icons.home_outlined);
  static Widget get menu => const Icon(Icons.menu);
  static Widget get appMenu => const Icon(Icons.apps);
  static Widget get chevronLeft => const Icon(Icons.chevron_left);
  static Widget get chevronRight => const Icon(Icons.chevron_right);
  static Widget get chevronUp => const Icon(Icons.expand_less);
  static Widget get chevronDown => const Icon(Icons.expand_more);
  static Widget get chevronUpSmall => const Icon(Icons.expand_less, size: 16);
  static Widget get chevronDownSmall => const Icon(Icons.expand_more, size: 16);
  static Widget get chevronRightSmall =>
      const Icon(Icons.chevron_right, size: 16);
  static Widget get chevronLeftSmall =>
      const Icon(Icons.chevron_left, size: 16);
  static Widget get closeSmall => const Icon(Icons.close, size: 16);

  // Action icons
  static Widget get search => const Icon(Icons.search);
  static Widget get info => const Icon(Icons.info_outline);
  static Widget get moreMenu => const Icon(Icons.more_vert);

  // Status icons
  static Widget get success => const Icon(Icons.check_circle_outline);
  static Widget get warning => const Icon(Icons.warning_amber);
  static Widget get error => const Icon(Icons.error_outline);
  static Widget get alarm => const Icon(Icons.alarm);
}
