/// Fixed square sizes an [IxIcon] can render at.
///
/// These mirror the Siemens iX `ix-icon` custom element's `:host` size
/// variants (12/16/24/32 px) so an icon always occupies a predictable,
/// discrete box regardless of its source (Material glyph, bundled SVG, or a
/// custom widget builder).
enum IxIconSize {
  /// 12x12 logical pixels.
  s12(12),

  /// 16x16 logical pixels.
  s16(16),

  /// 24x24 logical pixels. The default used by [IxIcon] when no size is
  /// specified.
  s24(24),

  /// 32x32 logical pixels.
  s32(32);

  /// Associates a size variant with its edge length in logical pixels.
  const IxIconSize(this.px);

  /// The edge length, in logical pixels, of the square icon box.
  final double px;
}
