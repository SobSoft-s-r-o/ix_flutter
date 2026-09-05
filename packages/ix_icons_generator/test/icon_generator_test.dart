import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ix_icons_generator/ix_icons_generator.dart';
import 'package:test/test.dart';

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

  test('cleanSvgContent removes fill="none" only on <g> elements', () {
    const svg =
        '<svg><g id="p" fill="none"><path fill="none" d="M0 0"/><g fill="none"><polygon points="0,0"/></g></g></svg>';
    final out = IconGenerator.cleanSvgContent(svg);
    expect(out, contains('<path fill="none"'));
    expect(RegExp(r'<g[^>]*fill="none"').hasMatch(out), isFalse);
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
}
