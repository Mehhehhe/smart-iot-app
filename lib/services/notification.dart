import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/db/threshold_settings.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeService();
//   runApp(const MyApp());
// }

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'KarrIoT', // id
    'KarrIoT SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // if (Platform.isIOS) {
  //   await flutterLocalNotificationsPlugin.initialize(
  //     const InitializationSettings(
  //       iOS: IOSInitializationSettings(),
  //     ),
  //   );
  // }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'KarrIoT',
      initialNotificationTitle: 'KarrIoT SERVICE',
      initialNotificationContent: 'Working ... ',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
// ignore: long-method
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

  // Fetching `threshold` sql, display notification
  service.on('threshDiff').listen((event) async {
    // Compare to thresh0
    final threshdb = ThresholdDatabase.instance;
    String currId = event!["encryptedKey"];
    // print("[Background] $currId , ${event["value"].runtimeType}");
    List thAll = await threshdb.getAllAvailableThresh();
    // print("[AllTHDB] $thAll");
    var activationTh = await threshdb.getThresh(currId);
    String status = "";

    if (service is AndroidServiceInstance &&
        event["value"].runtimeType == String) {
      if (await service.isForegroundService() &&
          num.parse(event["value"]) >= activationTh &&
          event["isMap"] == false) {
        flutterLocalNotificationsPlugin.show(
          888,
          'KarrIoT',
          "${event["name"]} exceeds the set threshold of $activationTh with value ${event["value"]}",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'KarrIoT',
              'KarrIoT SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              importance: Importance.high,
              priority: Priority.high,
              actions: [
                AndroidNotificationAction(
                  'KarrIoT',
                  'Exit',
                  cancelNotification: true,
                ),
              ],
            ),
          ),
        );
        status = "Error";
      } else if (await service.isForegroundService() &&
          num.parse(event["value"]) < activationTh &&
          event["isMap"] == false &&
          num.parse(event["value"]) > activationTh - 5) {
        flutterLocalNotificationsPlugin.show(
          888,
          'KarrIoT',
          "WARNING! ${event["name"]} was nearly reached the set threshold of $activationTh with value ${event["value"]}",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'KarrIoT',
              'KarrIoT SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
        status = "Warning";
      } else if (await service.isForegroundService() && event["isMap"]) {
        // Transform
        Map<String, dynamic> rMap = event["Value"];
        String errName = "";
        String errVal = "";
        List statusCheck = [];
        if (rMap["N"] >= activationTh["N"]) {
          errName += "N,";
          errVal += "N => ${rMap["N"]}, ";
          statusCheck.add("Error");
        } else if (rMap["N"] < activationTh["N"] &&
            rMap["N"] > activationTh["N"] - 5) {
          errName += "N,";
          errVal += "N => ${rMap["N"]}, ";
          statusCheck.add("Warning");
        }
        if (rMap["P"] >= activationTh["P"]) {
          errName += "P,";
          errVal += "P => ${rMap["P"]}, ";
          statusCheck.add("Error");
        } else if (rMap["P"] < activationTh["P"] &&
            rMap["P"] > activationTh["P"] - 5) {
          errName += "P,";
          errVal += "P => ${rMap["P"]}, ";
          statusCheck.add("Warning");
        }
        if (rMap["K"] >= activationTh["K"]) {
          errName += "K,";
          errVal += "K => ${rMap["K"]}, ";
          statusCheck.add("Error");
        } else if (rMap["K"] < activationTh["K"] &&
            rMap["K"] > activationTh["K"] - 5) {
          errName += "K,";
          errVal += "K => ${rMap["K"]}, ";
          statusCheck.add("Warning");
        }
        if (statusCheck.contains("Error")) {
          flutterLocalNotificationsPlugin.show(
            888,
            'KarrIoT',
            "${event["name"]}'s $errName exceeds the set threshold with value $errVal",
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'KarrIoT',
                'KarrIoT SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
          status = "Error";
        } else if (!statusCheck.contains("Error") &&
            statusCheck.contains("Warning")) {
          flutterLocalNotificationsPlugin.show(
            888,
            'KarrIoT',
            "${event["name"]}'s $errName was nearly reached the set threshold with value $errVal",
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'KarrIoT',
                'KarrIoT SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
                importance: Importance.high,
                priority: Priority.high,
              ),
            ),
          );
          status = "Warning";
        }
      }
    }
    // print("status noti => $status");
    if (status != "") {
      // init hist db
      final lc = LocalHistoryDatabase.instance;
      lc.update({
        "_id": event["id"],
        "comment": status,
      });
    }
  });
}
