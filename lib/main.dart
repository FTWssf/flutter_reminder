import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oil_palm_system/service/notification_service.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/model/notification.dart' as model_notification;
import 'package:oil_palm_system/database/notification_helper.dart';
import 'package:oil_palm_system/screen/add_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  // To run codebefore runApp();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
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
      home: const MyHomePage(title: Constant.appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<model_notification.Notification>? results;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd "); //HH:mm

  @override
  void initState() {
    super.initState();
    Helper().initializeDatabase();
    // readData();
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
    // NotificationService().showNotification();
  }

  void _routeAddScreen(NotificationHelper notificationHelper) async {
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    //   return AddScreen(
    //       // payload: '添加',
    //       );
    // }));
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ListenableProvider<NotificationHelper>.value(
          value: notificationHelper,
          child: AddScreen(),
        ),
      ),
    );
    //.then((value) => readData())
  }

  void readData() async {
    // NotificationService().scheduleNotification();
    // await Helper().initializeDatabase();
    // Helper().createTable();
    // model_notification.Notification notification =
    // model_notification.Notification('B', 'B', 'Heal', DateTime.now());
    // await NotificationHelper().create(notification);

    // final queryResults = await NotificationHelper().read();
    // setState(() {
    // results = queryResults;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => NotificationHelper(),
        child: Consumer<NotificationHelper>(
            builder: (context, notificationHelper, child) => Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                  ),
                  body: ListView.separated(
                    // itemCount: results?.length ?? 0,
                    itemCount: notificationHelper.items!.length,
                    itemBuilder: (context, index) {
                      // final item = results?[index];
                      final item = notificationHelper.items?[index];
                      return ListTile(
                        title: Text(
                          item?.action ?? '',
                          style: const TextStyle(
                              fontSize: 24.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 3.5),
                          child: Text(
                            '园主: ' +
                                (item?.name ?? '') +
                                '\n园地: ' +
                                (item?.land ?? ''),
                            style: const TextStyle(
                              fontSize: 21.0,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          dateFormat.format(item!.datetime ?? DateTime.now()),
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        thickness: 1,
                      );
                    },
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ListenableProvider<NotificationHelper>.value(
                            value: notificationHelper,
                            child: AddScreen(),
                          ),
                        ),
                      );
                    },
                    tooltip: '添加',
                    child: const Icon(Icons.add),
                  ),
                )));
  }
}
