/// Exposes Siemens IX font family identifiers for Flutter widgets.
class IxFonts {
  IxFonts._();

  /// Názov balíka pre `TextStyle.package` pri fontoch dodaných knižnicou.
  static const String packageName = 'ix_flutter';

  static const String robotoMono = 'Roboto Mono';
  static const List<String> robotoMonoFallback = ['Arial', 'Helvetica'];

  static const String jetBrainsMono = 'JetBrains Mono';
  static const List<String> jetBrainsMonoFallback = [
    'Courier New',
    'monospace',
  ];
}
