import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

/// Observer to automatically track screen views when navigation occurs
class ScreenViewObserver extends NavigatorObserver {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackScreen(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Optional: Track when user leaves a screen
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackScreen(newRoute);
    }
  }

  void _trackScreen(Route<dynamic> route) {
    String screenName = 'unknown';
    String screenClass = 'unknown';

    // Get screen name from route settings
    if (route.settings.name != null) {
      screenName = route.settings.name!;
    }

    // Get screen class from the widget
    if (route is PageRoute) {
      screenClass = route.settings.name ?? route.runtimeType.toString();
    }

    // Log screen view to Firebase
    _analytics.logEvent(
      name: 'screen_view',
      parameters: {
        'screen_name': screenName,
        'screen_class': screenClass,
      },
    );
    
    print('📊 Firebase Analytics: Screen viewed - $screenName ($screenClass)');
  }
}
