import 'package:flutter/material.dart';
import 'package:oil_palm_system/service/notification_service.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/model/notification.dart' as model_notification;
import 'package:oil_palm_system/database/notification_helper.dart';

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

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });
    // NotificationService().scheduleNotification();
    // await Helper().initializeDatabase();
    // Helper().createTable();
    model_notification.Notification notification =
        model_notification.Notification('B', 'B', 'Heal', DateTime.now());
    await NotificationHelper().create(notification);

    final results = await NotificationHelper().read();

    for (var result in results!) {
      print(result.id);
      print(result.land);
      print(result.action);
      print(result.datetime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            OutlinedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                NotificationService().cancelNotification();
              },
              child: const Text('Cancel Notification'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NewScreen extends StatelessWidget {
  String payload;

  NewScreen({
    @required this.payload = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload),
      ),
    );
  }
}
