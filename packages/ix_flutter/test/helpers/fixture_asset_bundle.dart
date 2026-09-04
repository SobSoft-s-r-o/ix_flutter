import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// AssetBundle, ktorý mapuje asset kľúče na súbory pod `test/fixtures/`.
/// Chýbajúci kľúč hodí FlutterError rovnako ako rootBundle.
class FixtureAssetBundle extends CachingAssetBundle {
  FixtureAssetBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final path = files[key];
    if (path == null) {
      throw FlutterError('Unable to load asset: "$key" (fixture missing)');
    }
    final bytes = File(path).readAsBytesSync();
    return ByteData.view(bytes.buffer);
  }
}
