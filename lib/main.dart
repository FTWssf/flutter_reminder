import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:intl/intl.dart';

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
    await NotificationService().init();
    List<Reminder>? reminders = await ReminderHelper().getPeriodicReminder();
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");

    if (reminders != null) {
      for (var reminder in reminders) {
        final dateTime = DateTime.parse(dateFormat.format(reminder.date!) +
                ' ' +
                (reminder.time ??= ''))
            .add((const Duration(days: 1)));

        final notification = NotificationTable(reminder.id, dateTime);
        int insertedId = await NotificationHelper().create(notification);
        await NotificationService()
            .scheduleNotification(reminder, insertedId, dateTime);
      }
    }

    return Future.value(true);
  });
}

void periodicTask() async {
  List<Reminder>? reminders = await ReminderHelper().getPeriodicReminder();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  if (reminders != null) {
    for (var reminder in reminders) {
      final dateTime = DateTime.parse(
              dateFormat.format(reminder.date!) + ' ' + (reminder.time ??= ''))
          .add((const Duration(days: 1)));
      // final dateTime = DateTime.parse(
      //         dateFormat.format(reminder.date!) + ' ' + (reminder.time ??= ''))
      //     .add((const Duration(minutes: 3)));
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
  await Workmanager().initialize(callbackDispatcher);

  // Workmanager().registerOneOffTask(
  //   "3", // Ignored on iOS
  //   'notificationPeriodicTask', // Ignored on iOS
  //   initialDelay: const Duration(seconds: 10),
  // );
  Workmanager().registerPeriodicTask(
    "4",
    "notificationPeriodicTask",
    // When no frequency is provided the default 15 minutes is set.
    // Minimum frequency is 15 min. Android will automatically change your frequency to 15 min if you have configured a lower frequency.
    frequency: const Duration(hours: 6),
  );

  runApp(const App());
  NotificationService().getPendingNotification();
  List<Reminder>? reminders = await ReminderHelper().getPeriodicReminder();
  List<NotificationTable>? abc = await NotificationHelper().read();
  if (abc != null) {
    for (var a in abc) {
      print('id: ${a.id} reminder: ${a.reminderId} date: ${a.date}');
    }
  }
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
}
