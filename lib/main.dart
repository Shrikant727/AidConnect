import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:aid_connect/locator.dart';
import 'package:aid_connect/scanner.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'advertise.dart';
import 'display.dart';
import 'home.dart';
import 'navigation.dart';
import 'constants.dart' as constants;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await initializeService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
  final service=FlutterBackgroundService();
  Widget build(BuildContext context) {
    service.startService();
    return MaterialApp(
      title: 'AidConnect',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: (settings) {
        // Handle dynamic parameters for different routes
        if (settings.name == '/display') {
          // Extract parameters from settings.arguments
          final Display args = settings.arguments as Display;
          return MaterialPageRoute(
            builder: (context) => Display(
              data: args.data,
              yourLatitude: args.yourLatitude,
              yourLongitude: args.yourLongitude,
            ),
          );
        }
        return null; // Return null for unknown routes
      },
      home: MyHomePage(title: 'AidConnect'),
    );
  }
}



Future<void> initializeService() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  final service = FlutterBackgroundService();

  // create awesome notifications channel
  NotificationChannel channel = NotificationChannel(
      channelKey: 'my_foreground',
      channelName: 'my_foreground',
      channelDescription: 'Notification tests as alerts',
      onlyAlertOnce: true,
      groupAlertBehavior: GroupAlertBehavior.Children,
      importance: NotificationImportance.Low,
      defaultPrivacy: NotificationPrivacy.Private,
      defaultColor: Colors.deepPurple,
      ledColor: Colors.deepPurple);

final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
  if (Platform.isIOS || Platform.isAndroid) {
    await awesomeNotifications.initialize(
        // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelKey: 'my_foreground',
              channelName: 'my_foreground',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple),
        ]);
  }


  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
    ),
  );
  awesomeNotifications.actionStream.listen((receivedNotification) async {
        if (receivedNotification.channelKey == 'my_foreground' &&
            receivedNotification.buttonKeyPressed == 'stop_action') {
          FlutterBackgroundService().invoke('stopService');
        }
      });
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  final awesomeNotifications = AwesomeNotifications();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        awesomeNotifications.createNotification(
          content: NotificationContent(
            id: 888,
            channelKey: 'my_foreground',
            title: 'AWESOME SERVICE',
            body: 'Updated at ${DateTime.now()}',
          ),
            actionButtons: [
                      NotificationActionButton(
                        key: 'stop_action',
                        label: 'Stop Service',
                      ),
                    ],
        );
      }
    }
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

}