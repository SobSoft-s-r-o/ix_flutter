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
/// The override is installed whatever the flags below say, and answers the
/// intent either way. `EditableText` registers its default through
/// [Action.overridable], which looks up the *nearest* override above the
/// field and hands it the overridden action as [Action.callingAction]; a
/// scope that is switched off gives the intent straight back to that action,
/// so `enabled: false` still means "Flutter's own behaviour" when an
/// enclosing scope -- [IxApplicationScaffold]'s, say -- is switched on.
/// Leaving the entry out instead would merely send the lookup one scope
/// further up.
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
/// And only a field this scope owns: the one nearest above it. A
/// `ScrollNotification` says where the *scroll* happened, not where the
/// focus is -- `FocusManager.instance.primaryFocus` is application-wide --
/// so a field that merely sits next to this scope, or one that a nested
/// scope has opted out, keeps its keyboard. That is the same owner the tap
/// trigger's [Actions] lookup resolves to.
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
  ///
  /// It holds for the whole of [child]: an enclosing scope that is switched
  /// on, such as the one [IxApplicationScaffold] installs around its frame,
  /// does not reach past this one.
  final bool enabled;

  /// Whether a tap outside a focused text input releases it.
  ///
  /// The two triggers are independent: turning this off leaves [onDrag]
  /// working, and vice versa. Like [enabled], it holds against an enclosing
  /// scope that has the trigger on.
  final bool onTapOutside;

  /// Whether dragging a scroll view releases a focused text input.
  ///
  /// Only a *user* drag counts. A programmatic `jumpTo`/`animateTo`, the
  /// ballistic settling after a fling and the field's own internal text
  /// scrolling all leave the keyboard alone. Like [enabled], the switch
  /// holds against an enclosing scope that has the trigger on.
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

  /// The override this scope installs, whatever the flags say.
  ///
  /// Built once and never swapped, so the entry is always there -- the
  /// nearest scope above a field is the one that answers for it -- and
  /// flipping a flag leaves the [Actions] element and its state in place.
  /// See [_IxTapOutsideAction].
  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    EditableTextTapOutsideIntent: _IxTapOutsideAction(this),
    EditableTextTapUpOutsideIntent: _IxTapUpOutsideAction(this),
  };

  /// Handles the pointer going down outside the field that raised [intent].
  ///
  /// Returns whether this scope answered for the field. `false` means it is
  /// switched off and [_IxTapOutsideAction] should hand the intent back to
  /// `EditableText`'s own action instead, so the field gets Flutter's
  /// platform behaviour -- which on a desktop platform is to unfocus -- and
  /// not merely the mobile half of it.
  bool _onTapOutside(EditableTextTapOutsideIntent intent) {
    _touchPointer = null;
    _touchDownPosition = null;
    if (!widget.enabled || !widget.onTapOutside) {
      return false;
    }
    if (!intent.focusNode.hasFocus) {
      return true;
    }
    if (intent.pointerDownEvent.kind == PointerDeviceKind.touch) {
      // Wait for the lift: this may still turn into a scroll.
      _touchPointer = intent.pointerDownEvent.pointer;
      _touchDownPosition = intent.pointerDownEvent.position;
      return true;
    }
    _release(intent.focusNode);
    return true;
  }

  /// Handles the lift of a touch that went down outside the field.
  ///
  /// Returns whether this scope answered, as [_onTapOutside] does. A
  /// switched-off scope hands the intent back to `EditableText`'s own
  /// tap-up-outside action, which does nothing of its own.
  bool _onTapUpOutside(EditableTextTapUpOutsideIntent intent) {
    final pointer = _touchPointer;
    final downPosition = _touchDownPosition;
    _touchPointer = null;
    _touchDownPosition = null;
    if (!widget.enabled || !widget.onTapOutside) {
      return false;
    }
    if (pointer == null ||
        downPosition == null ||
        pointer != intent.pointerUpEvent.pointer ||
        !intent.focusNode.hasFocus) {
      return true;
    }
    if ((intent.pointerUpEvent.position - downPosition).distance > kTouchSlop) {
      // A scroll (or any other drag), not a tap: leave the field alone.
      return true;
    }
    _release(intent.focusNode);
    return true;
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
    if (node == null || !_isTextInput(node.context) || !_owns(node)) {
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

  /// Whether this scope is the one that answers for [node].
  ///
  /// The notification proves that the *scroll* happened inside this subtree;
  /// `FocusManager.instance.primaryFocus` is application-wide and proves
  /// nothing about where the field is. Without this test a scroll here would
  /// release a field that merely sits next to this scope, or one that a
  /// nested scope has opted out of the behaviour. The scope nearest above
  /// the field owns it -- the same one the tap trigger's [Actions] lookup
  /// arrives at.
  bool _owns(FocusNode node) =>
      node.context?.findAncestorStateOfType<_IxKeyboardDismissScopeState>() ==
      this;

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
      child: Actions(actions: _actions, child: widget.child),
    );
  }
}

/// This scope's override of `EditableText`'s own tap-outside action.
///
/// `EditableText` registers that action with [Action.overridable]
/// (`editable_text.dart`), so the nearest [Actions] entry above the field
/// wins the lookup and is handed the action it overrode as
/// [Action.callingAction]. Delegating to it is how a scope that is switched
/// off asks for Flutter's own behaviour without copying the platform rules
/// out of the framework, and without an enclosing scope answering instead.
/// [Action.invoke] is protected, so that hand-back has to happen here rather
/// than in the [State]: the scope decides, this action delegates.
///
/// [Action.isActionEnabled] is left at its default `true` on purpose: a
/// disabled override is skipped and the lookup carries on to the next scope
/// up, which is exactly what this class exists to stop.
class _IxTapOutsideAction extends Action<EditableTextTapOutsideIntent> {
  _IxTapOutsideAction(this.scope);

  final _IxKeyboardDismissScopeState scope;

  @override
  Object? invoke(EditableTextTapOutsideIntent intent) =>
      scope._onTapOutside(intent) ? null : callingAction?.invoke(intent);
}

/// This scope's override of `EditableText`'s tap-up-outside action, whose own
/// default does nothing. See [_IxTapOutsideAction].
class _IxTapUpOutsideAction extends Action<EditableTextTapUpOutsideIntent> {
  _IxTapUpOutsideAction(this.scope);

  final _IxKeyboardDismissScopeState scope;

  @override
  Object? invoke(EditableTextTapUpOutsideIntent intent) =>
      scope._onTapUpOutside(intent) ? null : callingAction?.invoke(intent);
}
