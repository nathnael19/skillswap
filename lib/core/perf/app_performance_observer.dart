import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppPerformanceObserver extends NavigatorObserver {
  final Map<Route<dynamic>, Stopwatch> _activeRoutes = {};
  bool _frameTimingsAttached = false;

  void attachFrameTimings() {
    if (!kDebugMode || _frameTimingsAttached) return;
    _frameTimingsAttached = true;
    WidgetsBinding.instance.addTimingsCallback((timings) {
      for (final timing in timings) {
        final totalMs = (timing.totalSpan.inMicroseconds / 1000)
            .toStringAsFixed(2);
        if (timing.totalSpan > const Duration(milliseconds: 16)) {
          developer.log(
            'Slow frame: ${timing.totalSpan.inMilliseconds}ms',
            name: 'perf.frame',
          );
        }
        developer.log(
          'Frame build=${timing.buildDuration.inMilliseconds}ms '
          'raster=${timing.rasterDuration.inMilliseconds}ms total=$totalMs ms',
          name: 'perf.frame',
        );
      }
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (!kDebugMode) return;
    final watch = Stopwatch()..start();
    _activeRoutes[route] = watch;
    developer.log(
      'Route push: ${route.settings.name ?? route.runtimeType}',
      name: 'perf.nav',
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (!kDebugMode) return;
    final watch = _activeRoutes.remove(route);
    if (watch != null) {
      watch.stop();
      developer.log(
        'Route visible for ${watch.elapsedMilliseconds}ms: '
        '${route.settings.name ?? route.runtimeType}',
        name: 'perf.nav',
      );
    }
  }
}
