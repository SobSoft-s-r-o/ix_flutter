import 'package:ix_icons_generator/src/pubspec_asset_updater.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

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

  for (final specialPath in [
    'assets: icons',
    '[icons]',
    'assets: "icons"',
    "assets: 'icons'",
    r'assets: \icons',
  ]) {
    test('registers $specialPath as a YAML string and only once', () {
      const input = 'name: consumer\nflutter:\n  uses-material-design: true\n';

      final first = PubspecAssetUpdater.addAsset(input, specialPath);
      final parsed = loadYaml(first) as YamlMap;
      expect(parsed['flutter']['assets'], [specialPath + '/']);
      expect(parsed['flutter']['uses-material-design'], isTrue);

      final second = PubspecAssetUpdater.addAsset(first, specialPath);
      expect(second, first);
      expect((loadYaml(second) as YamlMap)['flutter']['assets'], [
        specialPath + '/',
      ]);
    });
  }

  test('recognizes an existing plain asset path containing spaces', () {
    const input = 'flutter:\n  assets:\n    - assets/icons with spaces/\n';
    expect((loadYaml(input) as YamlMap)['flutter']['assets'], [
      'assets/icons with spaces/',
    ]);

    expect(
      PubspecAssetUpdater.addAsset(input, 'assets/icons with spaces'),
      input,
    );
  });

  test('preserves a structured asset across a dedented comment', () {
    const input = '''flutter:
  assets:
    - path: assets/logo.png
  # Included only for this flavor.
      flavors:
        - vanilla
  uses-material-design: true
''';
    final original = (loadYaml(input) as YamlMap)['flutter']['assets'][0];
    expect(original, {
      'path': 'assets/logo.png',
      'flavors': ['vanilla'],
    });

    final output = PubspecAssetUpdater.addAsset(input, assetPath);
    final parsed = loadYaml(output) as YamlMap;

    expect(parsed['flutter']['assets'], [original, 'assets/svg/']);
    expect(parsed['flutter']['uses-material-design'], isTrue);
    expect(output, contains('  # Included only for this flavor.\n'));
    expect(PubspecAssetUpdater.addAsset(output, assetPath), output);
  });

  test('finds an already registered asset after a dedented comment', () {
    const input = '''flutter:
  assets:
    - assets/images/
# Generated icons follow.
    - assets/svg/
''';
    expect((loadYaml(input) as YamlMap)['flutter']['assets'], [
      'assets/images/',
      'assets/svg/',
    ]);

    final output = PubspecAssetUpdater.addAsset(input, assetPath);

    expect((loadYaml(output) as YamlMap)['flutter']['assets'], [
      'assets/images/',
      'assets/svg/',
    ]);
    expect(output, input);
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
