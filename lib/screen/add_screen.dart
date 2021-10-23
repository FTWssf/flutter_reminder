import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:oil_palm_system/database/notification_helper.dart';
import 'package:oil_palm_system/model/notification.dart' as model_notification;
import 'package:oil_palm_system/service/notification_service.dart';

class AddScreen extends StatefulWidget {
  final String payload;

  // late model_notification.Notification notification;

  AddScreen({Key? key, this.payload = ''}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreen();
}

class _AddScreen extends State<AddScreen> {
  // model_notification.Notification notification ;
  model_notification.Notification notification =
      model_notification.Notification('', '', '', null);
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss ");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加'),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: _body(context)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (notification.action!.isEmpty) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    title: Text("请输入目的"),
                    // content: Text("Hello World"),
                  );
                });
          }

          if (notification.name!.isEmpty) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    title: Text("请输入园主"),
                    // content: Text("Hello World"),
                  );
                });
          }

          if (notification.land!.isEmpty) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    title: Text("请输入园地"),
                    // content: Text("Hello World"),
                  );
                });
          }

          if (notification.datetime == null) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    title: Text("请选择提醒时间"),
                    // content: Text("Hello World"),
                  );
                });
          }

          if (notification.datetime!.isBefore(DateTime.now())) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AlertDialog(
                    title: Text("不能选择过去的时间"),
                    // content: Text("Hello World"),
                  );
                });
          }

          await NotificationHelper().create(notification);
          await NotificationService().scheduleNotification(notification);
          Navigator.pop(context);
        },
        tooltip: 'Increment',
        child: const Text('确认'),
      ),
    );
  }

  Widget _body(context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      _action(context),
      _name(context),
      _land(context),
      _datetime(context)
    ]);
  }

  String? validate(String value, String field) {
    if (value.isEmpty) {
      return "请输入$field";
    }
    return null;
  }

  Widget _action(context) {
    TextEditingController actionController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextField(
        controller: actionController,
        onChanged: (value) {
          notification.action = value;
        },
        decoration: InputDecoration(hintText: '目的'),
        //, errorText: validate(actionController.text, '目的')
      )
    ]);
  }

  Widget _name(context) {
    TextEditingController nameController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextField(
        controller: nameController,
        onChanged: (value) {
          notification.name = value;
        },
        decoration: InputDecoration(hintText: '园主'),
      )
    ]);
  }

  Widget _land(context) {
    TextEditingController landController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextField(
        controller: landController,
        onChanged: (value) {
          notification.land = value;
        },
        decoration: InputDecoration(hintText: '园地'),
      )
    ]);
  }

  Widget _datetime(context) {
    TextEditingController dateTimeController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextField(
        controller: dateTimeController,
        decoration: InputDecoration(hintText: '提醒时间'),
        readOnly: true,
        onTap: () {
          DatePicker.showDateTimePicker(context, showTitleActions: true,
              onChanged: (date) {
            // print('change $date in time zone ' +
            // date.timeZoneOffset.inHours.toString());
          }, onConfirm: (date) {
            // print('confirm $date');
            // notification.datetime = date;
            notification.datetime = date;
            dateTimeController.text = dateFormat.format(date);
          }, currentTime: DateTime.now().add(Duration(minutes: 1)));
        },
      )
    ]);
  }
}
