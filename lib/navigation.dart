
import 'package:flutter/material.dart';

import 'display.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
 new GlobalKey<NavigatorState>();
  Future<dynamic>? navigateTo(String routeName, {required Map<String, dynamic> arguments}) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: Display(data: arguments['data'], yourLatitude: arguments['yourLatitude'], yourLongitude: arguments['yourLongitude']));
  }
}