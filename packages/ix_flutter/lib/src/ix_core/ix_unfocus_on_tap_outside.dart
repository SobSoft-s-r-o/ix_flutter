import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Releases a focused text input when the user taps outside of it, taking
/// the on-screen keyboard down with it.
///
/// ## Why this exists
///
/// Flutter deliberately does *not* do this on a touch screen. Its default
/// tap-outside action (`_EditableTextTapOutsideAction` in
/// `packages/flutter/lib/src/widgets/editable_text.dart`) reads:
///
/// ```dart
/// // The focus dropping behavior is only present on desktop platforms.
/// switch (defaultTargetPlatform) {
///   case TargetPlatform.android:
///   case TargetPlatform.iOS:
///   case TargetPlatform.fuchsia:
///     // On mobile platforms, we don't unfocus on touch events unless
///     // they're in the web browser, but we do unfocus for all other kinds
///     // of events.
/// ```
///
/// So on an Android or iOS device a tap next to a focused `TextField` leaves
/// it focused and the soft keyboard covering the form. Users read that as a
/// bug; every app ends up re-implementing the dismissal by hand.
///
/// Wrapping a subtree in this widget gives every text input inside it the
/// behaviour users expect, on every platform, without touching the fields
/// themselves. [IxApplicationScaffold] does it for its whole frame by
/// default, so an app built on the scaffold needs no extra code.
///
/// ```dart
/// IxUnfocusOnTapOutside(
///   child: Padding(
///     padding: const EdgeInsets.all(16),
///     child: TextField(decoration: InputDecoration(labelText: 'Name')),
///   ),
/// )
/// ```
///
/// ## How it decides what "outside" means
///
/// It does not hit-test anything itself. Flutter's text fields and their
/// satellites -- the selection toolbar, the autofill dropdown, the
/// decoration's own icons -- all register a `TapRegion` in the same group
/// (`TextFieldTapRegion`, whose `groupId` defaults to `EditableText`), and
/// `RenderTapRegionSurface` already resolves a pointer against that group.
/// The field reports the result as an `EditableTextTapOutsideIntent`, which
/// Flutter documents as the override point:
///
/// > Override this [Intent] to modify the default behavior, which is to
/// > unfocus on a touch event on web and do nothing on other platforms.
///
/// This widget installs exactly that override for its subtree. Only the
/// field's own focus node is ever unfocused, so a focused button, menu tile
/// or any other non-text focus is untouched and the desktop focus ring is
/// never cleared by an unrelated tap. Taps are observed, never consumed:
/// the button you tapped to dismiss the keyboard still fires.
///
/// ## Taps, not scrolls
///
/// A touch that travels more than `kTouchSlop` before it lifts is a scroll,
/// not a tap, and keeps the keyboard: losing the keyboard the moment a form
/// is scrolled would be a worse bug than the one this fixes. Flutter
/// documents this refinement itself on `EditableTextTapUpOutsideIntent`
/// ("it's often desirable to only unfocus when the user taps outside of the
/// text field, but not when they scroll"). Mouse, stylus and unknown
/// pointers keep Flutter's own semantics and release the field on the
/// pointer *down*.
///
/// See also:
///
///  * [IxApplicationScaffold.unfocusOnTapOutside], the opt-out for apps
///    that want Flutter's stock behaviour back.
class IxUnfocusOnTapOutside extends StatefulWidget {
  /// Gives every text input in [child] the tap-to-dismiss behaviour.
  const IxUnfocusOnTapOutside({
    super.key,
    required this.child,
    this.enabled = true,
    this.dismissKeyboard = true,
  });

  /// The subtree whose text inputs are released on a tap outside them.
  final Widget child;

  /// Whether the behaviour is installed at all.
  ///
  /// `false` puts Flutter's platform default back for [child] -- a focused
  /// field survives a touch outside it on Android, iOS and Fuchsia -- while
  /// keeping this widget in the tree, so toggling it never remounts the
  /// subtree.
  final bool enabled;

  /// Whether the platform is asked to take the keyboard down explicitly.
  ///
  /// Releasing the focus closes the field's text-input connection, and
  /// Flutter's own `TextInput._clearClient()` already schedules a
  /// `TextInput.hide` when that happens -- so on a stock embedder the
  /// keyboard goes down either way. `true` sends that request immediately
  /// alongside the unfocus, ahead of the framework's teardown, as a safety
  /// net for an embedder that does not act on the connection closing. Set
  /// it to `false` if your app drives the IME itself and wants nothing but
  /// the focus change from this widget.
  final bool dismissKeyboard;

  @override
  State<IxUnfocusOnTapOutside> createState() => _IxUnfocusOnTapOutsideState();
}

class _IxUnfocusOnTapOutsideState extends State<IxUnfocusOnTapOutside> {
  /// The touch that went down outside a focused field, and where it landed.
  ///
  /// Held from the pointer down to the pointer up so the distance between
  /// the two can be measured; `null` for a pointer whose kind is released on
  /// the down event already.
  int? _touchPointer;
  Offset? _touchDownPosition;

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    EditableTextTapOutsideIntent: CallbackAction<EditableTextTapOutsideIntent>(
      onInvoke: _onTapOutside,
    ),
    EditableTextTapUpOutsideIntent:
        CallbackAction<EditableTextTapUpOutsideIntent>(
          onInvoke: _onTapUpOutside,
        ),
  };

  /// An empty map is not an override at all: the lookup walks past this
  /// widget and the field runs Flutter's own action.
  static const Map<Type, Action<Intent>> _passThrough =
      <Type, Action<Intent>>{};

  Object? _onTapOutside(EditableTextTapOutsideIntent intent) {
    _touchPointer = null;
    _touchDownPosition = null;
    if (!intent.focusNode.hasFocus) {
      return null;
    }
    if (intent.pointerDownEvent.kind == PointerDeviceKind.touch) {
      // Wait for the lift: this may still turn into a scroll.
      _touchPointer = intent.pointerDownEvent.pointer;
      _touchDownPosition = intent.pointerDownEvent.position;
      return null;
    }
    _release(intent.focusNode);
    return null;
  }

  Object? _onTapUpOutside(EditableTextTapUpOutsideIntent intent) {
    final pointer = _touchPointer;
    final downPosition = _touchDownPosition;
    _touchPointer = null;
    _touchDownPosition = null;
    if (pointer == null ||
        downPosition == null ||
        pointer != intent.pointerUpEvent.pointer ||
        !intent.focusNode.hasFocus) {
      return null;
    }
    if ((intent.pointerUpEvent.position - downPosition).distance > kTouchSlop) {
      // A scroll (or any other drag), not a tap: leave the field alone.
      return null;
    }
    _release(intent.focusNode);
    return null;
  }

  void _release(FocusNode node) {
    node.unfocus();
    if (widget.dismissKeyboard) {
      unawaited(_hideKeyboard());
    }
  }

  /// Asks the platform to take the IME down.
  ///
  /// Failures are swallowed on purpose: an embedder without a text-input
  /// plugin (a unit test host, an unusual platform) has nothing to answer,
  /// and the focus change has already closed the connection that keeps the
  /// keyboard up. Reporting it would only add noise to a test run.
  Future<void> _hideKeyboard() async {
    try {
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    } on PlatformException {
      // No IME to hide.
    } on MissingPluginException {
      // No text-input plugin on this embedder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: widget.enabled ? _actions : _passThrough,
      child: widget.child,
    );
  }
}
