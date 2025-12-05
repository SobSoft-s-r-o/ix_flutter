import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'edge_to_edge.dart';
import 'router/router.dart';
import 'theme_controller.dart';

class SiemensIxDemoApp extends StatefulWidget {
  const SiemensIxDemoApp({super.key});

  @override
  State<SiemensIxDemoApp> createState() => _SiemensIxDemoAppState();
}

class _SiemensIxDemoAppState extends State<SiemensIxDemoApp> {
  late final ThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ThemeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ThemeControllerScope(
          controller: _controller,
          child: MaterialApp.router(
            title: 'Siemens IX Flutter Demo',
            routerConfig: router,
            theme: _controller.buildTheme(ThemeMode.light),
            darkTheme: _controller.buildTheme(ThemeMode.dark),
            themeMode: _controller.mode,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              final overlayStyle = EdgeToEdge.overlayStyleFor(
                Theme.of(context),
              );
              SystemChrome.setSystemUIOverlayStyle(overlayStyle);
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
