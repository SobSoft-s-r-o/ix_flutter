import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An AssetBundle that maps asset keys to files under `test/fixtures/`.
/// A missing key throws a FlutterError, just like rootBundle.
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
