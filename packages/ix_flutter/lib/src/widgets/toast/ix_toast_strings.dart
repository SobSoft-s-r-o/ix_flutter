/// Localizable strings for [IxToastOverlay]'s chrome.
///
/// Toast [title]/`message`/`actionLabel` text is supplied per-toast via
/// [IxToastService.show]/[IxToastService.showToast] -- this class only
/// covers fixed chrome text that isn't part of any single toast's content,
/// currently the close button's accessible name.
class IxToastStrings {
  const IxToastStrings({this.closeToast = 'Close toast'});

  /// Accessible label and tooltip for a toast's close button.
  ///
  /// Upstream: `toast.tsx:81` (`aria-label="Close toast"`).
  final String closeToast;
}
