import 'package:ix_flutter/ix_flutter.dart';

/// Stand-in for the `lib/ix_icons.dart` that `ix_icons_generator` writes into
/// a consuming app, so the documentation snippets that use the generated
/// catalogue compile here too.
///
/// The real file declares one `IxIconData` constant per catalogue icon
/// (1 479 in `@siemens/ix-icons` 3.5.0) and is imported as
/// `package:your_app/ix_icons.dart`.
class IxIconsData {
  IxIconsData._();

  static const IxIconData home = IxIconData.asset('assets/ix_icons/home.svg');
  static const IxIconData menu = IxIconData.asset('assets/ix_icons/menu.svg');
  static const IxIconData close = IxIconData.asset('assets/ix_icons/close.svg');
}
