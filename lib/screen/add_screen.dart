import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
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
  bool _isLoading = false;
  model_notification.Notification notification =
      model_notification.Notification('', '', '', null);
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss ");

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Scaffold(
          appBar: AppBar(
            title: Text('添加'),
          ),
          body: LoadingOverlay(
            child: Padding(
                padding: const EdgeInsets.all(16.0), child: _body(context)),
            isLoading: _isLoading,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addItem,
            tooltip: '添加',
            child: const Text('确认'),
          ),
        ));
  }

  void _addItem() async {
    if (_isLoading) return;

    // if (notification.datetime!.isBefore(DateTime.now())) {
    //   return showDialog(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return const AlertDialog(
    //           title: Text("不能选择过去的时间"),
    //           // content: Text("Hello World"),
    //         );
    //       });
    // }

    if (!_formkey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    await NotificationHelper().create(notification);
    await NotificationService().scheduleNotification(notification);
    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  Widget _body(context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      _action(context),
      _name(context),
      _land(context),
      _datetime(context)
    ]);
  }

  Widget _action(context) {
    TextEditingController actionController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
        controller: actionController,
        onChanged: (value) {
          notification.action = value;
        },
        decoration: InputDecoration(hintText: '目的'),
        validator: _validateAction,
      )
    ]);
  }

  String? _validateAction(String? value) {
    if (value!.isEmpty) {
      return "请输入目的";
    } else if (value.length > 50) {
      return "目的不能多过50个数字";
    }
    return null;
  }

  Widget _name(context) {
    TextEditingController nameController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
        controller: nameController,
        onChanged: (value) {
          notification.name = value;
        },
        decoration: InputDecoration(hintText: '园主'),
        validator: _validateName,
      )
    ]);
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return "请输入园主";
    } else if (value.length > 50) {
      return "园主不能多过50个数字";
    }
    return null;
  }

  Widget _land(context) {
    TextEditingController landController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
        controller: landController,
        onChanged: (value) {
          notification.land = value;
        },
        decoration: InputDecoration(hintText: '园地'),
        validator: _validateLand,
      )
    ]);
  }

  String? _validateLand(String? value) {
    if (value!.isEmpty) {
      return "请输入园地";
    } else if (value.length > 50) {
      return "园地不能多过50个数字";
    }
    return null;
  }

  Widget _datetime(context) {
    TextEditingController dateTimeController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
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
        validator: _validateDatetime,
      )
    ]);
  }

  String? _validateDatetime(String? value) {
    if (value!.isEmpty) {
      return "请选择提醒时间";
    } else if (notification.datetime!.isBefore(DateTime.now())) {
      return "不能选择过去的时间";
    }
    return null;
  }
}
