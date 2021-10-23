import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/model/notification.dart' as model_notification;

class NotificationService {
  //Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  //instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    //Initialization Settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(Constant.androidIcon);

    //Initialization Settings for iOS
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    //initialize timezone package here
    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    ); // onSelectNotification: onSelectNotification
  }

  Future onSelectNotification(String payload) async {
    //Handle notification tapped logic here
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }
  // Future onSelectNotification(dynamic payload) async {
  //   Navigator.of(context).push(MaterialPageRoute(builder: (_) {
  //     return NewScreen(
  //       payload: payload,
  //     );
  //   }));
  // }

  // void requestIOSPermissions() {
  //   flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           IOSFlutterLocalNotificationsPlugin>()
  //       ?.requestPermissions(
  //         alert: true,
  //         badge: true,
  //         sound: true,
  //       );
  // }

  Future<void> requestIOSPermissions(BuildContext context) async {
    final status = await Permission.notification.status;
    switch (status) {
      case PermissionStatus.denied:
        final result = await Permission.notification.request();
        final isPermanentlyDenied = result.isPermanentlyDenied;
        if (result.isGranted) {
          _showDialog(context);
        } else if (isPermanentlyDenied) {
          openAppSettings();
        }
        break;
      case PermissionStatus.permanentlyDenied:
        openAppSettings();
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.restricted:
        break;
      case PermissionStatus.granted:
        _showDialog(context);
        break;
    }
  }

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Permission Granted'),
          content: const Text("Permission Granted"),
          actions: <Widget>[
            TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  Future<void> scheduleNotification(
      model_notification.Notification notification) async {
    // final dateTime = DateTime.now().add(Duration(seconds: 1));
    final dateTime = notification.datetime;
    final scheduledNotificationDateTime =
        tz.TZDateTime.from(dateTime!, tz.local);
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      '油棕',
      channelDescription: '提醒信息',
      priority: Priority.high,
      importance: Importance.max,
      icon: Constant.androidIcon,
    );
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        notification.action,
        '园主: ' +
            (notification.name ?? '') +
            ' 园地: ' +
            (notification.land ?? ''),
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
    // await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List> getPendingNotification() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  Future<void> showNotification() async {
    const android = AndroidNotificationDetails('id', 'channel ',
        channelDescription: 'description',
        priority: Priority.high,
        importance: Importance.max);
    const iOS = IOSNotificationDetails();
    const platform = NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Flutter devs', 'Flutter Local Notification Demo', platform,
        payload: 'Welcome to the Local Notification demo ');
  }
}
