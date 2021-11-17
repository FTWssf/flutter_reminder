import 'package:flutter/material.dart';

import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/screen/reminder/reminder_list_screen.dart';
import 'package:oil_palm_system/screen/land/land_list_screen.dart';
import 'package:oil_palm_system/service/notification_service.dart';
import 'package:oil_palm_system/widget/bottom_nav_bar.dart';

void main() async {
  // To run codebefore runApp();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  Helper().initializeDatabase();

  runApp(const App());
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
