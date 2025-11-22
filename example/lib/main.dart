import 'package:flutter/material.dart';

import 'app.dart';
import 'edge_to_edge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  await EdgeToEdge.configureSystemUi(brightness: brightness);
  runApp(const SiemensIxDemoApp());
}
