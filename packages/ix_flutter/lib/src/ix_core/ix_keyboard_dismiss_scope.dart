import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Releases a focused text input -- taking the on-screen keyboard down with
/// it -- when the user taps outside the field or scrolls the page.
///
/// ## Why this exists
///
/// Flutter does neither of those things by default on a touch screen, and
/// both defaults live too far down to fix once for a whole app.
///
/// **Tapping outside.** The default tap-outside action
/// (`_EditableTextTapOutsideAction` in
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
/// so on Android or iOS a tap next to a focused `TextField` leaves it
/// focused and the keyboard covering the form.
///
/// **Scrolling.** Flutter dismisses on scroll per scroll view, through
/// `ScrollView.keyboardDismissBehavior`, and the app-wide default opts out
/// (`packages/flutter/lib/src/widgets/scroll_configuration.dart`):
///
/// ```dart
/// ScrollViewKeyboardDismissBehavior getKeyboardDismissBehavior(BuildContext context) =>
///     ScrollViewKeyboardDismissBehavior.manual;
/// ```
///
/// so every list, grid and `SingleChildScrollView` in the app has to opt in
/// one by one.
///
/// Wrapping a subtree in this widget gives every text input inside it the
/// behaviour users expect, on every platform, without touching the fields or
/// the scroll views. [IxApplicationScaffold] does it for its whole frame by
/// default, so an app built on the scaffold needs no extra code.
///
/// ```dart
/// IxKeyboardDismissScope(
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
/// ## Which scrolls count
///
/// A `NotificationListener<ScrollNotification>` watches the subtree, so one
/// scope covers every scroll view under it -- lists, grids,
/// `SingleChildScrollView`s and nested scrollables alike -- and it never
/// absorbs the notification. Only a `ScrollUpdateNotification` carrying
/// `dragDetails` releases the field, mirroring Flutter's own
/// `ScrollViewKeyboardDismissBehavior.onDrag`: a programmatic `jumpTo` or
/// `animateTo`, the ballistic settle after a fling and a mouse wheel carry
/// no drag details, and a field scrolling its own text never dismisses its
/// own keyboard. As with the tap trigger, only a focused *text input* is
/// released; a focused button survives a scroll.
///
/// ## Taps, not scrolls
///
/// For the tap trigger a touch that travels more than `kTouchSlop` before it
/// lifts is a drag, not a tap, and is left to the scroll trigger to judge --
/// so dragging a page that cannot scroll keeps the keyboard. Flutter
/// documents this refinement itself on `EditableTextTapUpOutsideIntent`
/// ("it's often desirable to only unfocus when the user taps outside of the
/// text field, but not when they scroll"). Mouse, stylus and unknown
/// pointers keep Flutter's own semantics and release the field on the
/// pointer *down*.
///
/// See also:
///
///  * [IxApplicationScaffold.dismissKeyboardOnInteraction], the opt-out for
///    apps that want Flutter's stock behaviour back.
class IxKeyboardDismissScope extends StatefulWidget {
  /// Gives every text input in [child] the dismiss-on-interaction behaviour.
  const IxKeyboardDismissScope({
    super.key,
    required this.child,
    this.enabled = true,
    this.onTapOutside = true,
    this.onDrag = true,
    this.dismissKeyboard = true,
  });

  /// The subtree whose text inputs are released on a tap or a scroll.
  final Widget child;

  /// Whether the behaviour is installed at all.
  ///
  /// `false` puts Flutter's platform defaults back for [child] -- a focused
  /// field survives both a touch outside it on Android, iOS and Fuchsia and
  /// a scroll of any scroll view -- while keeping this widget in the tree,
  /// so toggling it never remounts the subtree.
  final bool enabled;

  /// Whether a tap outside a focused text input releases it.
  ///
  /// The two triggers are independent: turning this off leaves [onDrag]
  /// working, and vice versa.
  final bool onTapOutside;

  /// Whether dragging a scroll view releases a focused text input.
  ///
  /// Only a *user* drag counts. A programmatic `jumpTo`/`animateTo`, the
  /// ballistic settling after a fling and the field's own internal text
  /// scrolling all leave the keyboard alone.
  final bool onDrag;

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
  State<IxKeyboardDismissScope> createState() => _IxKeyboardDismissScopeState();
}

class _IxKeyboardDismissScopeState extends State<IxKeyboardDismissScope> {
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

  /// Releases a focused text input when the user drags a scroll view.
  ///
  /// Always returns `false`, so the notification keeps bubbling and every
  /// other listener still sees the scroll.
  bool _onScroll(ScrollNotification notification) {
    if (!widget.enabled || !widget.onDrag || !_isUserDrag(notification)) {
      return false;
    }
    final node = FocusManager.instance.primaryFocus;
    if (node == null || !_isTextInput(node.context)) {
      return false;
    }
    // The field scrolling its own content (a selection drag in a long
    // single-line input) must not take its own keyboard away.
    if (_isTextInput(notification.context)) {
      return false;
    }
    _release(node);
    return false;
  }

  /// Whether [notification] reports a scroll the user is driving with a
  /// pointer, as opposed to a `jumpTo`/`animateTo`, a ballistic settle after
  /// a fling, or a mouse wheel -- none of which carry drag details.
  ///
  /// Only [ScrollUpdateNotification] counts, exactly as in Flutter's own
  /// `ScrollViewKeyboardDismissBehavior.onDrag` (`scroll_view.dart`). A
  /// [ScrollStartNotification] would be wrong: when a scroll view is the
  /// sole member of the gesture arena, a plain *tap* on it is accepted as a
  /// drag and starts one with real drag details, without ever moving the
  /// offset. Keying off the update means the content actually has to move.
  static bool _isUserDrag(ScrollNotification notification) =>
      notification is ScrollUpdateNotification &&
      notification.dragDetails != null;

  /// Whether [context] sits inside a text input.
  ///
  /// Used both to decide that the current focus is a field -- a focused
  /// button or menu tile must keep its focus through a scroll -- and to
  /// recognise a field's own internal scroll view.
  static bool _isTextInput(BuildContext? context) =>
      context != null &&
      (context.widget is EditableText ||
          context.findAncestorWidgetOfExactType<EditableText>() != null);

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
    // Both wrappers stay in the tree whatever the flags say -- they gate
    // themselves -- so flipping a flag never remounts the subtree.
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Actions(
        actions: widget.enabled && widget.onTapOutside
            ? _actions
            : _passThrough,
        child: widget.child,
      ),
    );
  }
}
