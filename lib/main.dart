import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/screen/reminder/reminder_list_screen.dart';
import 'package:oil_palm_system/screen/land/land_list_screen.dart';
import 'package:oil_palm_system/service/notification_service.dart';
import 'package:oil_palm_system/widget/bottom_nav_bar.dart';

import 'package:oil_palm_system/model/notification_table.dart';
import 'package:oil_palm_system/model/reminder.dart';
import 'package:oil_palm_system/database/reminder_helper.dart';
import 'package:oil_palm_system/database/notification_helper.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'notificationPeriodicTask':
      case Workmanager.iOSBackgroundTask:
        await periodicTask();
        break;
      default:
        break;
    }

    return Future.value(true);
  });
}

Future<void> periodicTask() async {
  await NotificationService().init();

  final pendingList = await NotificationService().getPendingNotification();
  for (var item in pendingList) {
    final notification = await NotificationHelper().fetch(item.id);
    if (notification != null) {
      if (notification.date!.isBefore(DateTime.now())) {
        final id = notification.id ?? 0;
        await NotificationService().cancelNotification(id);
        await NotificationService().showNotification(item.title, id);
      }
    }
  }

  List<Reminder>? reminders = await ReminderHelper().getPeriodicReminder();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  if (reminders != null) {
    for (var reminder in reminders) {
      final dateTime = DateTime.parse(
              dateFormat.format(DateTime.now()) + ' ' + (reminder.time ??= ''))
          .add((const Duration(days: 1)));

      final notification = NotificationTable(reminder.id, dateTime);
      int insertedId = await NotificationHelper().create(notification);
      await NotificationService()
          .scheduleNotification(reminder, insertedId, dateTime);
    }
  }
}

void main() async {
  // To run codebefore runApp();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Helper().initializeDatabase();

  switch (Platform.operatingSystem) {
    case 'ios':
      await Workmanager().initialize(callbackDispatcher,
          isInDebugMode: (kReleaseMode ? false : true));
      break;
    case 'android':
      await Workmanager().cancelByUniqueName("4");
      await Workmanager().initialize(callbackDispatcher,
          isInDebugMode: (kReleaseMode ? false : true));
      Workmanager().registerPeriodicTask(
        "5",
        "notificationPeriodicTask",
        frequency: (kReleaseMode
            ? const Duration(hours: 3)
            : const Duration(minutes: 15)),
      );
      break;
    default:
      break;
  }

  runApp(const App());
  // final pendingList = await NotificationService().getPendingNotification();
  // for (var a in pendingList) {
  //   print(
  //       'list body: ${a.body} title: ${a.title} payload: ${a.payload} id: ${a.id}}');
  // }
  // List<Reminder>? reminders = await ReminderHelper().getPeriodicReminder();
  // List<NotificationTable>? abc = await NotificationHelper().read();
  // if (abc != null) {
  //   for (var a in abc) {
  //     print('id: ${a.id} reminder: ${a.reminderId} date: ${a.date}');
  //   }
  // }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ReminderListScreen(),
    LandListScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constant.appName,
      // onGenerateRoute: _routes(),
      theme: ThemeData(
        primarySwatch: Constant.themeColor,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(Constant.appName),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar:
            BottomNavBar(index: _selectedIndex, itemTapped: _onItemTapped),
      ),
    );
  }

  // RouteFactory _routes() {
  //   return (settings) {
  //     final arguments = settings.arguments;
  //     Widget screen;
  //     switch (settings.name) {
  //       case LocationsRoute:
  //         screen = Locations();
  //         break;
  //       case LocationDetailRoute:
  //         screen = LocationDetail(arguments['id']);
  //         break;
  //       default:
  //         return null;
  //     }
  //     return MaterialPageRoute(builder: (BuildContext context) => screen);
  //   };
  // }
}
