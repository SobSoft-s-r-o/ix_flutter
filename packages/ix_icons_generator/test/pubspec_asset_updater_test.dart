import 'package:ix_icons_generator/src/pubspec_asset_updater.dart';
import 'package:test/test.dart';

void main() {
  const assetPath = 'assets/svg';

  test('adds assets only to the root flutter mapping', () {
    const input = '''name: consumer
dependencies:
  flutter:
    sdk: flutter
flutter:
  uses-material-design: true
''';

    expect(PubspecAssetUpdater.addAsset(input, assetPath), '''name: consumer
dependencies:
  flutter:
    sdk: flutter
flutter:
  assets:
    - assets/svg/
  uses-material-design: true
''');
  });

  test('appends a root flutter mapping when it is absent', () {
    const input = '''name: consumer
dependencies:
  flutter:
    sdk: flutter
''';

    expect(PubspecAssetUpdater.addAsset(input, assetPath), '''name: consumer
dependencies:
  flutter:
    sdk: flutter
flutter:
  assets:
    - assets/svg/
''');
  });

  test('appends to an existing root flutter assets list', () {
    const input = '''flutter:
  assets:
    - assets/images/
  uses-material-design: true
''';

    expect(PubspecAssetUpdater.addAsset(input, assetPath), '''flutter:
  assets:
    - assets/images/
    - assets/svg/
  uses-material-design: true
''');
  });

  test('applying the same asset update twice is unchanged', () {
    const input = '''flutter:
  uses-material-design: true
''';
    const expected = '''flutter:
  assets:
    - assets/svg/
  uses-material-design: true
''';

    final first = PubspecAssetUpdater.addAsset(input, assetPath);
    final second = PubspecAssetUpdater.addAsset(first, assetPath);

    expect(first, expected);
    expect(second, expected);
  });

  test('preserves unrelated nested assets mappings', () {
    const input = '''generator:
  assets:
    index: tool/assets.json
flutter:
  uses-material-design: true
''';

    expect(PubspecAssetUpdater.addAsset(input, assetPath), '''generator:
  assets:
    index: tool/assets.json
flutter:
  assets:
    - assets/svg/
  uses-material-design: true
''');
  });

  test('an unrelated matching asset entry does not suppress registration', () {
    const input = '''generator:
  assets:
    - assets/svg/
flutter:
  uses-material-design: true
''';

    final output = PubspecAssetUpdater.addAsset(input, assetPath);

    expect(
      RegExp(r'^    - assets/svg/$', multiLine: true).allMatches(output),
      hasLength(2),
    );
    expect(output, contains('flutter:\n  assets:\n    - assets/svg/\n'));
  });

  test('refuses a root flutter assets mapping', () {
    const input = '''flutter:
  assets:
    icons: assets/icons
''';

    expect(
      () => PubspecAssetUpdater.addAsset(input, assetPath),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('flutter.assets'),
        ),
      ),
    );
  });

  test('refuses an inline root flutter mapping', () {
    const input = 'flutter: {uses-material-design: true}\n';

    expect(
      () => PubspecAssetUpdater.addAsset(input, assetPath),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('top-level flutter'),
        ),
      ),
    );
  });
}
