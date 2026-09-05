/// Where an [IxToastOverlay] anchors its stack of toasts on screen.
///
/// Every position is right-aligned (upstream `toast-container.scss:25-33`
/// only defines a top/bottom axis; the toast stack is always pinned to the
/// trailing edge), 16 logical pixels from the screen edge, and safe-area
/// aware.
enum IxToastPosition {
  /// Anchored to the bottom-right corner. The 2.0 default.
  bottomRight,

  /// Anchored to the top-right corner. The 1.x-compatible default (see
  /// `IxToastOverlay.position`).
  topRight,
}
