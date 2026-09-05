import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:ix_flutter/src/ix_core/ix_focus_ring.dart';
import 'package:ix_flutter/src/ix_core/ix_motion.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';
import 'package:ix_flutter/src/ix_icons/ix_icons.dart';
import 'package:ix_flutter/src/ix_theme/components/ix_blind_theme.dart';
import 'package:ix_flutter/src/ix_theme/ix_theme_builder.dart';

export 'package:ix_flutter/src/ix_theme/components/ix_blind_theme.dart'
    show IxBlindVariant;

/// A collapsible container that mirrors the Siemens iX `<ix-blind>` component.
///
/// A blind consists of a header area (chevron, label, optional icon, optional sublabel,
/// optional header actions) and a content area.
///
/// ## Expanded state
///
/// The widget is uncontrolled by default: leaving [expanded] `null` makes it
/// manage its own state internally, starting from [initiallyExpanded] and
/// toggling on every header tap.
///
/// ```dart
/// const IxBlind(title: 'Details', child: Text('...'))
/// ```
///
/// Passing [expanded] makes it controlled: it then only ever *requests* a
/// state change through [onExpandedChanged] and renders whatever [expanded]
/// says, exactly like the 1.x contract.
///
/// ```dart
/// IxBlind(
///   title: 'Details',
///   expanded: _open,
///   onExpandedChanged: (value) => setState(() => _open = value),
///   child: const Text('...'),
/// )
/// ```
///
/// See also:
/// * [IxBlindVariant], which defines the visual style of the blind.
class IxBlind extends StatefulWidget {
  /// Creates a Siemens iX blind.
  const IxBlind({
    super.key,
    required this.title,
    this.subtitle,
    this.variant = IxBlindVariant.filled,
    this.icon,
    this.headerActions,
    this.expanded,
    this.initiallyExpanded = false,
    this.onExpandedChanged,
    this.disabled = false,
    required this.child,
  });

  /// The main label of the blind.
  final String title;

  /// An optional secondary label displayed below the title.
  final String? subtitle;

  /// The visual variant of the blind.
  final IxBlindVariant variant;

  /// An optional icon displayed before the title.
  ///
  /// Typically an [IxIcons] widget.
  final Widget? icon;

  /// Optional widgets to display on the right side of the header.
  ///
  /// Rendered as a sibling of the header outside its `Semantics` node (see
  /// the class-level doc), so header actions such as an [IconButton] keep
  /// their own accessible name instead of inheriting [title].
  final Widget? headerActions;

  /// Whether the blind content is visible.
  ///
  /// When `null` (the default), the blind is *uncontrolled*: it manages its
  /// own expanded state internally, starting from [initiallyExpanded], and
  /// flips it on every header tap.
  ///
  /// When non-null, the blind is *controlled*: it always renders exactly
  /// this value and never changes it on its own. The caller must update
  /// [expanded] (typically from [onExpandedChanged]) to make the header
  /// responsive to taps.
  final bool? expanded;

  /// The expanded state used on first build when [expanded] is `null`
  /// (uncontrolled mode). Ignored once [expanded] is set.
  ///
  /// Defaults to `false` for 1.x source compatibility. The iX Flutter 2.0
  /// breaking-changes plan flips this default to `true`.
  final bool initiallyExpanded;

  /// Called with the requested expanded state when the user taps the
  /// header.
  ///
  /// In uncontrolled mode (see [expanded]) this is a notification: the
  /// blind has already updated itself by the time this fires. In
  /// controlled mode it is a request: the blind keeps rendering the old
  /// [expanded] value until the caller supplies a new one.
  final ValueChanged<bool>? onExpandedChanged;

  /// Whether the blind is disabled.
  ///
  /// A disabled header exposes `enabled: false` in its semantics and
  /// ignores taps; it never calls [onExpandedChanged].
  final bool disabled;

  /// The content to display when the blind is expanded.
  final Widget child;

  @override
  State<IxBlind> createState() => _IxBlindState();
}

class _IxBlindState extends State<IxBlind> {
  /// Backing store for the uncontrolled contract; only consulted when
  /// [IxBlind.expanded] is `null`. `late` because it reads [widget], which
  /// is not yet assigned during this object's own field initialization.
  late bool _internal = widget.initiallyExpanded;

  // Tracks whether the header's InkWell currently has keyboard focus, so the
  // focus ring can be painted around the *whole* blind (see build() below)
  // rather than clipped away by the outer Container's `Clip.antiAlias`.
  bool _headerFocused = false;

  /// The effective expanded state: the controlled [IxBlind.expanded] value
  /// when set, otherwise the internally-tracked uncontrolled state.
  bool get _expanded => widget.expanded ?? _internal;

  @override
  void didUpdateWidget(covariant IxBlind oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Transitioning from controlled to uncontrolled: seed the internal
    // state from the last controlled value so the next toggle continues
    // from where the caller left it, instead of jumping back to
    // `initiallyExpanded`.
    if (oldWidget.expanded != null && widget.expanded == null) {
      _internal = oldWidget.expanded!;
    }
  }

  void _toggle() {
    final next = !_expanded;
    if (widget.expanded == null) {
      setState(() => _internal = next);
    }
    widget.onExpandedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final blindTheme =
        themeData.extension<IxBlindTheme>() ?? IxBlindTheme.fallback(themeData);
    final style = blindTheme.style(widget.variant);
    final isExpanded = _expanded;
    final sizeDuration = IxMotion.of(context, IxMotion.defaultTime);

    // Resolve colors based on state (hover, active handled by InkWell/Material)
    // But we need to set the base style.
    // Since we use InkWell, we can rely on its splash/highlight, but we need
    // to set the container background and border.

    // The ring wraps the whole Container (not just the header) because the
    // header sits flush against the Container's own edge: a ring painted
    // around the header alone would extend past that edge and be clipped
    // away by the Container's `Clip.antiAlias`. Splitting the header into
    // its own clipped box (so the ring could sit outside it) would also
    // have to make its border/corner-radius switch between "all four
    // corners rounded" (collapsed) and "top corners only, no bottom
    // border" (expanded) in step with the content box below it -- a purely
    // visual change with no test coverage of its own, so it is left for a
    // dedicated follow-up rather than folded into this semantics task.
    return IxFocusRing(
      focused: _headerFocused,
      borderRadius: BorderRadius.circular(blindTheme.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: style.background,
          border: Border.all(
            color: style.borderColor,
            width: blindTheme.borderWidth,
          ),
          borderRadius: BorderRadius.circular(blindTheme.borderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IxBlindHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              icon: widget.icon,
              headerActions: widget.headerActions,
              expanded: isExpanded,
              onTap: widget.disabled ? null : _toggle,
              style: style,
              disabled: widget.disabled,
              onFocusChanged: (focused) =>
                  setState(() => _headerFocused = focused),
            ),
            AnimatedSize(
              // Under reduced motion `sizeDuration` is `Duration.zero`, and
              // `AnimationController.forward()` on a zero-duration
              // controller completes synchronously. If the *same*
              // RenderAnimatedSize is then asked to animate an actual size
              // change (collapsed <-> expanded) while its duration is
              // zero, that synchronous completion re-enters
              // `markNeedsLayout()` from inside its own `performLayout()`,
              // which Flutter forbids ("A RenderObject must not re-dirty
              // itself while still being laid out") -- reproduced by
              // tapping an uncontrolled blind under `disableAnimations:
              // true` (see test/blind/ix_blind_test.dart). Re-keying by
              // `isExpanded` only while duration is zero forces a
              // brand-new RenderAnimatedSize on every toggle instead of
              // reusing the old one: a render object's *first* layout
              // always adopts the child's size outright (no tween, so
              // nothing to restart), giving the instant state change
              // reduced motion promises without ever running the code
              // path that trips this assertion. A non-zero duration keeps
              // the key `null` so the same render object persists and the
              // size transition keeps animating smoothly.
              key: sizeDuration == Duration.zero ? ValueKey(isExpanded) : null,
              duration: sizeDuration,
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: ExcludeSemantics(
                excluding: !isExpanded,
                child: isExpanded
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: style.borderColor,
                              width: blindTheme.borderWidth,
                            ),
                          ),
                        ),
                        child: widget.child,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IxBlindHeader extends StatelessWidget {
  const _IxBlindHeader({
    required this.title,
    this.subtitle,
    this.icon,
    this.headerActions,
    required this.expanded,
    this.onTap,
    required this.style,
    required this.disabled,
    this.onFocusChanged,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? headerActions;
  final bool expanded;
  final VoidCallback? onTap;
  final IxBlindStyle style;
  final bool disabled;
  final ValueChanged<bool>? onFocusChanged;

  @override
  Widget build(BuildContext context) {
    final ixTypography = IxTheme.maybeOf(context)?.typography ?? IxTypography();

    // Determine foreground color
    final foregroundColor = style.foreground;

    // One semantics node for the whole header: `excludeSemantics: true`
    // drops whatever the chevron, optional icon, title/subtitle `Text`s and
    // the `InkWell` itself would otherwise contribute (including the
    // `Focus` node's own `isFocusable`), so every accessible property of
    // the button -- label, hint, button/expanded/enabled state, the tap
    // action, and focusability -- is set explicitly right here instead of
    // being assembled from several descendants.
    final header = Semantics(
      button: true,
      enabled: !disabled,
      expanded: expanded,
      focusable: !disabled,
      label: title,
      hint: subtitle,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent, // Container handles background
        child: InkWell(
          onTap: onTap,
          focusColor: Colors.transparent,
          onFocusChange: onFocusChanged,
          hoverColor: style.hoverBackground.withValues(
            alpha: style.hoverBackground.a * 0.1,
          ), // Use a subtle overlay

          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: IxCommonGeometry.space3, // 1rem
              vertical: IxCommonGeometry.space1, // 0.5rem
            ),
            constraints: const BoxConstraints(minHeight: 48.0), // 3rem
            child: Row(
              children: [
                // Chevron
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0.0,
                  duration: IxMotion.of(context, IxMotion.defaultTime),
                  child: IconTheme(
                    data: IconThemeData(color: foregroundColor, size: 24),
                    child: IxIcons.chevronRight,
                  ),
                ),
                const SizedBox(width: IxCommonGeometry.space1), // 0.5rem
                // Optional Icon
                if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: foregroundColor, size: 24),
                    child: icon!,
                  ),
                  const SizedBox(width: IxCommonGeometry.space1),
                ],

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: ixTypography.label.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: ixTypography.bodySm.copyWith(
                            color: foregroundColor.withValues(
                              alpha: foregroundColor.a * 0.8,
                            ), // Slightly lighter
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (headerActions == null) {
      return header;
    }
    // Header actions are a sibling of the header's `Semantics` node, not a
    // descendant of it: `excludeSemantics` above only reaches down its own
    // subtree, but keeping them out of the `InkWell`/`Expanded` column
    // entirely means they never inherit the header's tap target or get
    // swallowed by its exhaustive button/expanded semantics.
    return Row(
      children: [
        Expanded(child: header),
        const SizedBox(width: IxCommonGeometry.space1),
        headerActions!,
      ],
    );
  }
}

/// A helper widget to display a list of blinds with proper spacing.
class IxBlindAccordion extends StatelessWidget {
  const IxBlindAccordion({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 8.0), // 0.5rem spacing
          children[i],
        ],
      ],
    );
  }
}
