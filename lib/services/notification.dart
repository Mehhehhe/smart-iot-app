// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotifyUser {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   String message;
//   final String _channelId = "1000";
//   final String _channelName = "SMART_IOT_APP_NOTIFICATION_CHANNEL";
//   final String _channelDescription =
//       "SMART_IOT_APP_NOTIFICATION_CHANNEL_DETAIL";

//   NotifyUser() {
//     message = "No message";
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   }

//   String initialize() {
//     var initializationSettings = const InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//       //iOS: ,
//     );
//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: (payload) {
//         message = payload;
//       },
//     );
//     return message ?? "notFound";
//   }

//   pushNotification(Importance im, Priority pr,
//       [String title, String message, String details]) async {
//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//         '10000', _channelName,
//         channelDescription: details ?? "", importance: im, priority: pr);
//     var platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(122, title ?? "Notification",
//         message ?? "Notification message", platformChannelSpecifics,
//         payload: "userPressedNoti");
//   }
// }
