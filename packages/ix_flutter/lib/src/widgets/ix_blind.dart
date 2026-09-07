import 'package:flutter/material.dart';
import 'package:ix_flutter/src/ix_core/ix_collapsible.dart';
import 'package:ix_flutter/src/ix_core/ix_common_geometry.dart';
import 'package:ix_flutter/src/ix_core/ix_focus_ring.dart';
import 'package:ix_flutter/src/ix_core/ix_motion.dart';
import 'package:ix_flutter/src/ix_core/ix_typography.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon_key.dart';
import 'package:ix_flutter/src/ix_icons/ix_icon_size.dart';
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
  /// Typically an [IxIcon]. The header sizes it to 24px through an ambient
  /// [IconTheme], which both [Icon] and [IxIcon] follow; pass
  /// [IxIcon.size] to override that for one icon.
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

  /// The header's own focus node, so the blind can put the focus back on it
  /// when the content that held it is collapsed away.
  final FocusNode _headerFocusNode = FocusNode(debugLabel: 'IxBlind.header');

  /// The effective expanded state: the controlled [IxBlind.expanded] value
  /// when set, otherwise the internally-tracked uncontrolled state.
  bool get _expanded => widget.expanded ?? _internal;

  @override
  void dispose() {
    _headerFocusNode.dispose();
    super.dispose();
  }

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
    // No explicit animate-on-change call needed: build() below always
    // passes the current `_expanded` to IxCollapsible, whose own
    // didUpdateWidget drives the transition when that value changes.
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
              focused: _headerFocused,
              focusNode: _headerFocusNode,
              onFocusChanged: (focused) =>
                  setState(() => _headerFocused = focused),
            ),
            // IxCollapsible reveals the content from its top edge and only
            // ever clips: the content subtree keeps the same shape and the
            // same elements from the first frame of the transition to the
            // last, whatever the duration is (see its own doc comment).
            IxCollapsible(
              expanded: isExpanded,
              // The reduced-motion-aware duration depends on MediaQuery,
              // re-read on every build so a live "reduce motion" toggle is
              // honoured without touching IxCollapsible's own controller
              // value directly.
              duration: IxMotion.of(context, IxMotion.defaultTime),
              returnFocusTo: _headerFocusNode,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: style.borderColor,
                      width: blindTheme.borderWidth,
                    ),
                  ),
                ),
                child: widget.child,
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
    required this.focused,
    required this.focusNode,
    this.onFocusChanged,
  });

  /// The type scale used when no [IxThemeBuilder] theme is present, built
  /// once rather than on every [build] of every theme-less header.
  static final IxTypography _defaults = IxTypography();

  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? headerActions;
  final bool expanded;
  final VoidCallback? onTap;
  final IxBlindStyle style;
  final bool disabled;

  /// Whether the header's `InkWell` currently holds the keyboard focus, as
  /// last reported through [onFocusChanged].
  final bool focused;

  /// The header's focus node, owned by the state so it can put the focus
  /// back here when the content that held it collapses away.
  final FocusNode focusNode;
  final ValueChanged<bool>? onFocusChanged;

  @override
  Widget build(BuildContext context) {
    final ixTypography = IxTheme.maybeOf(context)?.typography ?? _defaults;

    // Determine foreground color
    final foregroundColor = style.foreground;

    // One semantics node for the tappable part of the header:
    // `excludeSemantics: true` drops whatever the chevron, optional icon,
    // title/subtitle `Text`s and the `InkWell` itself would otherwise
    // contribute (including the `Focus` node's own `isFocusable` and
    // `isFocused`), so every accessible property of the button -- label,
    // hint, button/expanded/enabled state, the tap action, focusability and
    // the *current* focus -- is set explicitly right here instead of being
    // assembled from several descendants. `headerActions` (below) stays
    // outside this node so it keeps its own accessible name.
    //
    // `focused:` republishes the very state the focus ring around the blind
    // is already painted from, so assistive technology can follow the
    // keyboard through a stack of blinds (WCAG 2.4.7) -- the same fix
    // `_NavigationTile` and `IxResponsiveDataView`'s sortable headers
    // carry.
    //
    // The padding and 48px minimum height live *inside* the `InkWell`
    // (wrapping its content `Row`), not on an ancestor `Container`: a
    // `Row` only ever passes its children a *loose* max-height, never its
    // own enforced `minHeight` -- an `InkWell` sized by an ancestor
    // `Container`'s `minHeight` instead would still shrink to the
    // intrinsic height of the chevron/title content, leaving the padding
    // margins untappable and the interactive element itself under the
    // 48px touch-target minimum.
    final semanticHeader = Semantics(
      button: true,
      enabled: !disabled,
      expanded: expanded,
      focusable: !disabled,
      // `null`, not `false`, while disabled: `focusable` and `focused` share
      // one tristate flag, and `focused` is applied *after* `focusable`, so
      // an explicit `focused: false` would put a disabled header back into
      // the traversal order it must stay out of.
      focused: disabled ? null : focused,
      label: title,
      hint: subtitle,
      onTap: onTap,
      // `excludeSemantics` drops the `InkWell`'s own `focus` action along
      // with the rest of its node, so a screen reader could see that this
      // header is focusable but had no way to focus it. Republished here.
      onFocus: disabled ? null : focusNode.requestFocus,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent, // Container handles background
        child: InkWell(
          onTap: onTap,
          focusNode: focusNode,
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
                    child: const IxIcon.key(
                      IxIconKey.chevronRight,
                      size: IxIconSize.s24,
                    ),
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
      return semanticHeader;
    }
    // `headerActions` is a sibling of `semanticHeader`, not a descendant --
    // it stays outside the `excludeSemantics` boundary above (so it keeps
    // its own accessible name) and outside the `InkWell`'s tap target.
    // `Center` keeps it aligned with the header content's own vertical
    // centreline even when a subtitle makes the header taller than
    // `headerActions`'s own natural height; the trailing-edge-only padding
    // gives it the same 16px margin from the blind's border that the
    // header's own content gets from its `Container`'s padding above.
    //
    // Deliberately *not* `crossAxisAlignment: CrossAxisAlignment.stretch`:
    // this Row sits inside the blind's `mainAxisSize.min` Column, which in
    // turn can receive an unbounded height from its own ancestor (e.g. a
    // bare `Scaffold` body in a widget test) -- `stretch` would then ask
    // this Row's children to be infinitely tall ("BoxConstraints forces an
    // infinite height"), reproducible by pumping any `IxBlind` at all.
    // `Center` already gives `headerActions` the vertical alignment
    // `stretch` was meant to provide, without requiring a bounded row
    // height to do it.
    return Row(
      children: [
        Expanded(child: semanticHeader),
        Padding(
          padding: const EdgeInsetsDirectional.only(
            end: IxCommonGeometry.space3,
          ),
          child: Center(child: headerActions!),
        ),
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
