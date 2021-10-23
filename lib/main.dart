import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oil_palm_system/service/notification_service.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/model/notification.dart' as model_notification;
import 'package:oil_palm_system/database/notification_helper.dart';
import 'package:oil_palm_system/screen/add_screen.dart';

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
        primarySwatch: Colors.blue,
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
    readData();
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
    // NotificationService().scheduleNotification();
  }

  void _routeAddScreen() async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return AddScreen(
        payload: '添加',
      );
    })).then((value) => setState(() {
          readData();
        }));
  }

  void readData() async {
    // NotificationService().scheduleNotification();
    // await Helper().initializeDatabase();
    // Helper().createTable();
    // model_notification.Notification notification =
    // model_notification.Notification('B', 'B', 'Heal', DateTime.now());
    // await NotificationHelper().create(notification);
    final queryResults = await NotificationHelper().read();
    setState(() {
      results = queryResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       const Text(
      //         'You have pushed the button this many times:',
      //       ),
      //       Text(
      //         '$_counter',
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //       OutlinedButton(
      //         style: ButtonStyle(
      //           foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      //         ),
      //         onPressed: () {
      //           NotificationService().cancelNotification();
      //         },
      //         child: const Text('Cancel Notification'),
      //       )
      //     ],
      //   ),
      // ),
      body: ListView.separated(
        // Let the ListView know how many items it needs to build.
        itemCount: results?.length ?? 0,
        // Provide a builder function. This is where the magic happens.
        // Convert each item into a widget based on the type of item it is.
        itemBuilder: (context, index) {
          final item = results?[index];

          return ListTile(
            title: Text(
              item?.action ?? '',
              style: Theme.of(context).textTheme.headline5,
            ),
            subtitle: Text(
              '园主: ' + (item?.name ?? '') + '\n园地: ' + (item?.land ?? ''),
              style: Theme.of(context).textTheme.headline6,
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
        onPressed: _routeAddScreen,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
