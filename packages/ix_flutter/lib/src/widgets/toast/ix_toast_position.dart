/// Where an [IxToastOverlay] anchors its stack of toasts on screen.
///
/// Every position is right-aligned (upstream `toast-container.scss:25-33`
/// only defines a top/bottom axis; the toast stack is always pinned to the
/// trailing edge) and safe-area aware: 32 logical pixels from whichever of
/// the screen's top/bottom edges this anchors to, 16 from the trailing
/// edge. The deprecated `IxToastOverlay.position` (`Alignment`) path keeps
/// 1.0.2's 16px offset on every edge instead.
enum IxToastPosition {
  /// Anchored to the bottom-right corner. The 2.0 default.
  bottomRight,

  /// Anchored to the top-right corner. The 1.x-compatible default (see
  /// `IxToastOverlay.position`).
  topRight,
}
