import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/database/reminder_helper.dart';
import 'package:oil_palm_system/database/notification_helper.dart';

import 'package:oil_palm_system/model/notification_table.dart';
import 'package:oil_palm_system/model/reminder.dart';

import 'package:oil_palm_system/res/constant.dart';

import 'package:oil_palm_system/screen/add_screen.dart';

import 'package:oil_palm_system/service/notification_service.dart';

import 'package:oil_palm_system/widget/bottom_nav_bar.dart';

void main() async {
  // To run codebefore runApp();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  Helper().initializeDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constant.appName,
      theme: ThemeData(
        primarySwatch: Constant.themeColor,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Reminder>? results;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd"); //HH:mm
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
  }

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    LandScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _routeAddScreen(ReminderHelper reminderHelper) async {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ListenableProvider<ReminderHelper>.value(
          value: reminderHelper,
          child: const AddScreen(),
        ),
      ),
    );
  }

  void _cancelNotification(
      Reminder reminder, ReminderHelper reminderHelper) async {
    // if (reminder.cancelled == 0) {
    List<NotificationTable>? notifications =
        await NotificationHelper().getReminderNotification(reminder.id ?? 0);
    for (var notification in notifications!) {
      await NotificationService().cancelNotification(notification.id ?? 0);
    }
    reminder.cancelled = 1;
    reminderHelper.update(reminder);
    NotificationService().getPendingNotification();

    Fluttertoast.showToast(
        msg: "取消成功",
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: Constant.toastFontSize);
    Navigator.pop(context);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ReminderHelper(),
        child: Consumer<ReminderHelper>(
            builder: (context, reminderHelper, child) => Scaffold(
                  appBar: AppBar(
                    title: const Text(Constant.appName),
                  ),
                  body: ListView.separated(
                    itemCount: (reminderHelper.items == null
                        ? 0
                        : reminderHelper.items!.length),
                    itemBuilder: (context, index) {
                      final item = reminderHelper.items?[index];

                      return Slidable(
                          actionPane: const SlidableDrawerActionPane(),
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: '取消',
                              color: (item!.cancelled == 1)
                                  ? Colors.grey
                                  : Colors.red,
                              icon: Icons.cancel,
                              onTap: () => {
                                if (item.cancelled == 0)
                                  {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("注意"),
                                            content: const Text("取消此通知？"),
                                            actions: [
                                              TextButton(
                                                child: const Text("返回"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("确认"),
                                                onPressed: () =>
                                                    _cancelNotification(
                                                        item, reminderHelper),
                                              ),
                                            ],
                                          );
                                        })
                                  }
                              },
                            ),
                          ],
                          child: ListTile(
                            title: Text(
                              item.action ?? '',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: (item.cancelled == 1)
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3.5),
                              child: Text(
                                '园主: ' +
                                    (item.name ?? '') +
                                    '\n园地: ' +
                                    (item.land ?? ''),
                                style: const TextStyle(
                                  fontSize: 21.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              dateFormat.format(
                                      item.startDate ?? DateTime.now()) +
                                  '\n' +
                                  dateFormat
                                      .format(item.endDate ?? DateTime.now()) +
                                  '\n' +
                                  item.time.toString(),
                              style: const TextStyle(
                                fontSize: 17.0,
                                color: Colors.black,
                              ),
                            ),
                          ));
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        thickness: 1,
                      );
                    },
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      _routeAddScreen(reminderHelper);
                    },
                    tooltip: '添加',
                    child: const Icon(Icons.add),
                  ),
                  bottomNavigationBar: BottomNavBar(
                      index: _selectedIndex, itemTapped: _onItemTapped),
                )));
  }
}

class LandScreen extends StatelessWidget {
  const LandScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('123');
  }
}
