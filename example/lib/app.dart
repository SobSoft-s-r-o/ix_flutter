import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ix_flutter/ix_flutter.dart';

import 'edge_to_edge.dart';
import 'router/router.dart';
import 'theme_controller.dart';
import 'toast_provider.dart';

class IxDemoApp extends StatefulWidget {
  const IxDemoApp({super.key});

  @override
  State<IxDemoApp> createState() => _IxDemoAppState();
}

class _IxDemoAppState extends State<IxDemoApp> {
  late final ThemeController _controller;
  late final IxToastService _toastService;

  @override
  void initState() {
    super.initState();
    _controller = ThemeController();
    _toastService = IxToastService();
  }

  @override
  void dispose() {
    _controller.dispose();
    _toastService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToastProvider(
      service: _toastService,
      child: AnimatedBuilder(
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
                  child: Stack(
                    children: [
                      if (child != null) child,
                      IxToastOverlay(service: _toastService),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
