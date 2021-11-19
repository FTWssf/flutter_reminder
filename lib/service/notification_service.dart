import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/model/reminder.dart';

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

  // Future onSelectNotification(dynamic payload) async {
  // Navigator.of(context).push(MaterialPageRoute(builder: (_) {
  //   return NewScreen(
  //     payload: payload,
  //   );
  // }));
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
      barrierDismissible: false, // user must tap button
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
      Reminder reminder, int insertedId, DateTime datetime) async {
    // final dateTime = DateTime.now().add(Duration(seconds: 1));;
    if (datetime.isBefore(DateTime.now())) return;
    final scheduledNotificationDateTime = tz.TZDateTime.from(
        datetime, tz.getLocation('Asia/Kuala_Lumpur')); //tz.local

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '',
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
        insertedId,
        reminder.land,
        '油棕收割',
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    // await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<List> getPendingNotification() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var a in pendingNotificationRequests) {
      print(
          'body: ${a.body} title: ${a.title} payload: ${a.payload} id: ${a.id}}');
    }
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
