import 'package:flutter/widgets.dart';

/// Siemens IX animation-duration tokens, with built-in reduced-motion
/// support.
///
/// Mirrors the upstream duration custom properties declared in
/// `_common.scss` (`_common.scss:29,76,147,165,131`). Widgets in this
/// library resolve their animation durations through [IxMotion.of] instead
/// of hard-coding a [Duration] literal, so that a user with the platform's
/// "reduce motion" accessibility setting enabled
/// (`MediaQuery.disableAnimationsOf`) gets an instant state change instead
/// of a transition.
abstract final class IxMotion {
  /// No animation (0 ms).
  static const Duration short = Duration.zero;

  /// The default transition duration (150 ms) used by most micro
  /// interactions, such as small size and rotation changes.
  static const Duration defaultTime = Duration(milliseconds: 150);

  /// A medium transition duration (300 ms), used by larger transitions such
  /// as a toast entering or leaving the screen.
  static const Duration medium = Duration(milliseconds: 300);

  /// A slow transition duration (500 ms).
  static const Duration slow = Duration(milliseconds: 500);

  /// An extra-slow transition duration (1000 ms).
  static const Duration xSlow = Duration(milliseconds: 1000);

  /// Resolves [duration] against the ambient reduced-motion preference.
  ///
  /// Returns [Duration.zero] when `MediaQuery.disableAnimationsOf(context)`
  /// is `true`, and [duration] unchanged otherwise. Call this at the point a
  /// duration is assigned to an `Animated*` widget or `AnimationController`:
  ///
  /// ```dart
  /// AnimatedSize(
  ///   duration: IxMotion.of(context, IxMotion.defaultTime),
  ///   child: child,
  /// )
  /// ```
  static Duration of(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
