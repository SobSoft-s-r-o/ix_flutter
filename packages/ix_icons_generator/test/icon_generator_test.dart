import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ix_icons_generator/ix_icons_generator.dart';
import 'package:test/test.dart';

/// Sentinel for `clientForArchive(shasum:)` distinguishing "not passed"
/// (use the tarball's real sha1) from an explicit `null` (omit the field).
const Object _useRealShasum = Object();

void main() {
  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('gen_'));
  tearDown(() => tmp.deleteSync(recursive: true));

  MockClient client({String version = '3.5.0'}) => MockClient((req) async {
    if (req.url.path == '/@siemens/ix-icons') {
      return http.Response(
        File('test/fixtures/registry.json').readAsStringSync(),
        200,
      );
    }
    if (req.url.path.endsWith('ix-icons-$version.tgz')) {
      return http.Response.bytes(
        File('test/fixtures/package.tgz').readAsBytesSync(),
        200,
      );
    }
    return http.Response('not found', 404);
  });

  /// Serves an in-memory `.tgz` built from [archive] under the 3.5.0
  /// version entry, with [shasum] (defaulting to the tarball's real sha1)
  /// as `dist.shasum`.
  MockClient clientForArchive(
    Archive archive, {
    Object? shasum = _useRealShasum,
  }) {
    final tarball = GZipEncoder().encodeBytes(
      TarEncoder().encodeBytes(archive),
    );
    final declared = identical(shasum, _useRealShasum)
        ? sha1.convert(tarball).toString()
        : shasum as String?;
    final registry = json.encode({
      'versions': {
        '3.5.0': {
          'dist': {
            'tarball':
                'https://registry.npmjs.org/@siemens/ix-icons/-/ix-icons-3.5.0.tgz',
            if (declared != null) 'shasum': declared,
          },
        },
      },
      'dist-tags': {'latest': '3.5.0'},
    });
    return MockClient((req) async {
      if (req.url.path == '/@siemens/ix-icons') {
        return http.Response(registry, 200);
      }
      if (req.url.path.endsWith('ix-icons-3.5.0.tgz')) {
        return http.Response.bytes(tarball, 200);
      }
      return http.Response('not found', 404);
    });
  }

  Archive validArchive() => Archive()
    ..add(
      ArchiveFile.string('package/svg/a.svg', '<svg><path d="M0 0"/></svg>'),
    )
    ..add(
      ArchiveFile.string('package/svg/b-c.svg', '<svg><path d="M1 1"/></svg>'),
    );

  test('cleanSvgContent removes fill="none" from <g> elements', () {
    const svg =
        '<svg><g id="p" fill="none"><path d="M0 0"/><g fill="none"><polygon points="0,0"/></g></g></svg>';
    final out = IconGenerator.cleanSvgContent(svg);
    expect(RegExp(r'<g[^>]*fill="none"').hasMatch(out), isFalse);
  });

  test('cleanSvgContent removes fill="none" from the root <svg>', () {
    const svg =
        '<svg width="512" height="512" viewBox="0 0 512 512" fill="none" '
        'xmlns="http://www.w3.org/2000/svg"><desc>dashboard</desc>'
        '<path fill-rule="evenodd" d="M0 0"/></svg>';
    final out = IconGenerator.cleanSvgContent(svg);
    expect(RegExp(r'<svg[^>]*fill="none"').hasMatch(out), isFalse);
    expect(out, contains('fill-rule="evenodd"'));
    expect(out, contains('viewBox="0 0 512 512"'));
    expect(out, contains('<desc>dashboard</desc>'));
  });

  test('cleanSvgContent removes fill="none" from an unstroked shape', () {
    const svg = '<svg><path fill="none" d="M0 0"/></svg>';
    final out = IconGenerator.cleanSvgContent(svg);
    expect(out, isNot(contains('fill="none"')));
    expect(out, contains('d="M0 0"'));
  });

  test('cleanSvgContent keeps fill="none" on a stroked shape', () {
    const svg =
        '<svg><path fill="none" stroke="#000" stroke-width="2" d="M0 0"/></svg>';
    final out = IconGenerator.cleanSvgContent(svg);
    expect(out, contains('fill="none"'));
    expect(out, contains('stroke="#000"'));
  });

  test('generated assets carry no root-level fill="none"', () async {
    final archive = Archive()
      ..add(
        ArchiveFile.string(
          'package/svg/blank.svg',
          '<svg viewBox="0 0 24 24" fill="none"><path d="M0 0"/></svg>',
        ),
      );
    await IconGenerator.generateIcons(
      outputDir: '${tmp.path}/lib',
      assetsDir: '${tmp.path}/assets/ix_icons',
      client: clientForArchive(archive),
    );
    final asset = File(
      '${tmp.path}/assets/ix_icons/blank.svg',
    ).readAsStringSync();
    expect(asset, isNot(contains('fill="none"')));
  });

  test(
    'generates IxIconsData constants, deprecated getters and no flutter_svg import',
    () async {
      await IconGenerator.generateIcons(
        outputDir: '${tmp.path}/lib',
        assetsDir: '${tmp.path}/assets/ix_icons',
        client: client(),
      );
      final code = File('${tmp.path}/lib/ix_icons.dart').readAsStringSync();
      expect(code, contains('// @siemens/ix-icons 3.5.0'));
      expect(code, contains("import 'package:ix_flutter/ix_flutter.dart';"));
      expect(code, isNot(contains('flutter_svg')));
      expect(
        code,
        contains(
          "static const IxIconData bC = IxIconData.asset('assets/ix_icons/b-c.svg');",
        ),
      );
      expect(code, contains("@Deprecated('Use IxIcon(IxIconsData.bC)')"));
      expect(File('${tmp.path}/assets/ix_icons/a.svg').existsSync(), isTrue);
    },
  );

  test(
    'iconsVersion selects the tarball and fails clearly when absent',
    () async {
      expect(
        () => IconGenerator.generateIcons(
          outputDir: '${tmp.path}/lib',
          assetsDir: '${tmp.path}/a',
          client: client(),
          iconsVersion: '9.9.9',
        ),
        throwsA(
          predicate((e) => e.toString().contains('Version 9.9.9 not found')),
        ),
      );
    },
  );

  test('legacyGetters=false omits the IxIcons class', () async {
    await IconGenerator.generateIcons(
      outputDir: '${tmp.path}/lib',
      assetsDir: '${tmp.path}/a',
      client: client(),
      legacyGetters: false,
    );
    final code = File('${tmp.path}/lib/ix_icons.dart').readAsStringSync();
    expect(code, isNot(contains('class IxIcons {')));
  });

  test('rejects a tarball entry that escapes the temp directory', () async {
    final archive = validArchive()
      ..add(ArchiveFile.string('package/../../escape.svg', '<svg/>'));
    await expectLater(
      IconGenerator.generateIcons(
        outputDir: '${tmp.path}/lib',
        assetsDir: '${tmp.path}/assets/ix_icons',
        client: clientForArchive(archive),
      ),
      throwsA(
        predicate(
          (e) => e.toString().contains('escapes the extraction directory'),
        ),
      ),
    );
  });

  test('skips symbolic-link entries', () async {
    final archive = validArchive()
      ..add(ArchiveFile.symlink('package/svg/link.svg', '/etc/passwd'));
    await IconGenerator.generateIcons(
      outputDir: '${tmp.path}/lib',
      assetsDir: '${tmp.path}/assets/ix_icons',
      client: clientForArchive(archive),
    );
    final code = File('${tmp.path}/lib/ix_icons.dart').readAsStringSync();
    expect(code, isNot(contains('link.svg')));
    expect(File('${tmp.path}/assets/ix_icons/a.svg').existsSync(), isTrue);
  });

  test('a rejected entry leaves no extraction directory behind', () async {
    Set<String> extractionDirs() => Directory.systemTemp
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path)
        .where((p) => p.contains('ix_icons_'))
        .toSet();

    final before = extractionDirs();
    final archive = validArchive()
      ..add(ArchiveFile.string('package/../../escape.svg', '<svg/>'));
    await expectLater(
      IconGenerator.generateIcons(
        outputDir: '${tmp.path}/lib',
        assetsDir: '${tmp.path}/assets/ix_icons',
        client: clientForArchive(archive),
      ),
      throwsA(anything),
    );
    expect(extractionDirs().difference(before), isEmpty);
  });

  test('sanitises identifiers that Dart cannot spell', () async {
    final archive = Archive()
      ..add(ArchiveFile.string('package/svg/3d-view.svg', '<svg/>'))
      ..add(ArchiveFile.string('package/svg/class.svg', '<svg/>'))
      ..add(ArchiveFile.string('package/svg/ok.svg', '<svg/>'));
    await IconGenerator.generateIcons(
      outputDir: '${tmp.path}/lib',
      assetsDir: '${tmp.path}/assets/ix_icons',
      client: clientForArchive(archive),
    );
    final code = File('${tmp.path}/lib/ix_icons.dart').readAsStringSync();
    expect(code, contains('IxIconData icon3dView ='));
    expect(code, contains('IxIconData class_ ='));
    expect(code, contains('IxIconData ok ='));
  });

  test('fails on two icons that collapse to one identifier', () async {
    final archive = Archive()
      ..add(ArchiveFile.string('package/svg/a-b.svg', '<svg/>'))
      ..add(ArchiveFile.string('package/svg/a_b.svg', '<svg/>'));
    await expectLater(
      IconGenerator.generateIcons(
        outputDir: '${tmp.path}/lib',
        assetsDir: '${tmp.path}/assets/ix_icons',
        client: clientForArchive(archive),
      ),
      throwsA(predicate((e) => e.toString().contains('Duplicate icon'))),
    );
  });

  test('rejects a tarball whose sha1 does not match dist.shasum', () async {
    await expectLater(
      IconGenerator.generateIcons(
        outputDir: '${tmp.path}/lib',
        assetsDir: '${tmp.path}/assets/ix_icons',
        client: clientForArchive(validArchive(), shasum: 'deadbeef'),
      ),
      throwsA(predicate((e) => e.toString().contains('sha1 mismatch'))),
    );
  });

  test(
    'a registry without dist.shasum still generates, marked unknown',
    () async {
      await IconGenerator.generateIcons(
        outputDir: '${tmp.path}/lib',
        assetsDir: '${tmp.path}/assets/ix_icons',
        client: clientForArchive(validArchive(), shasum: null),
      );
      final code = File('${tmp.path}/lib/ix_icons.dart').readAsStringSync();
      expect(code, contains('tarball sha1 unknown'));
    },
  );
}
