/// Main entry point for the ix_flutter package.
///
/// Exposes Siemens iX-themed widgets, theming utilities, and token definitions
/// for building Flutter apps that follow the Siemens iX design system.
library ix_flutter;

export 'src/ix_colors/ix_theme_color_tokens.dart';
export 'src/ix_colors/ix_theme_family.dart';
export 'src/ix_core/ix_fonts.dart';
export 'src/ix_core/ix_typography.dart';
export 'src/ix_core/ix_common_geometry.dart';
export 'src/ix_theme/components/ix_app_header_theme.dart';
export 'src/ix_theme/components/ix_app_menu_theme.dart';
export 'src/ix_theme/components/ix_badge_theme.dart';
export 'src/ix_theme/components/ix_button_theme.dart';
export 'src/ix_theme/components/ix_card_theme.dart';
export 'src/ix_theme/components/ix_checkbox_theme.dart';
export 'src/ix_theme/components/ix_chip_theme.dart';
export 'src/ix_theme/components/ix_breadcrumb_theme.dart';
export 'src/ix_theme/components/ix_label_theme.dart';
export 'src/ix_theme/components/ix_modal_theme.dart';
export 'src/ix_theme/components/ix_toggle_theme.dart';
export 'src/ix_theme/components/ix_radio_theme.dart';
export 'src/ix_theme/components/ix_slider_theme.dart';
export 'src/ix_theme/components/ix_spinner_theme.dart';
export 'src/ix_theme/components/ix_scrollbar_theme.dart';
export 'src/ix_theme/components/ix_upload_theme.dart';
export 'src/ix_theme/components/ix_form_field_theme.dart';
export 'src/ix_theme/components/ix_sidebar_theme.dart';
export 'src/ix_theme/components/ix_tabs_theme.dart';
export 'src/ix_theme/ix_theme_builder.dart';
export 'src/ix_theme/ix_custom_palette.dart';
// Note: ix_icons are no longer exported from library due to licensing restrictions.
// Users must generate icons using: dart run ix_flutter:generate_icons
// See doc/ix_icons.md for complete documentation.
export 'src/widgets/ix_breadcrumb.dart';
export 'src/widgets/ix_blind.dart';
export 'src/ix_theme/components/ix_blind_theme.dart';
export 'src/widgets/ix_spinner.dart';
export 'src/widgets/ix_application_scaffold.dart';
export 'src/widgets/ix_empty_state.dart';
export 'src/widgets/ix_dropdown_button.dart';
export 'src/widgets/ix_responsive_data_view.dart';
export 'src/widgets/i18n/ix_responsive_data_view_strings.dart';
export 'src/widgets/toast/ix_toast_data.dart';
export 'src/widgets/toast/ix_toast_service.dart';
export 'src/widgets/toast/ix_toast_overlay.dart';
export 'src/widgets/toast/ix_toast.dart';
