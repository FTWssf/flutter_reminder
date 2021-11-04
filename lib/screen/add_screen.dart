import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:oil_palm_system/database/reminder_helper.dart';
import 'package:oil_palm_system/database/notification_helper.dart';
import 'package:oil_palm_system/model/reminder.dart';
import 'package:oil_palm_system/model/notification_table.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/service/notification_service.dart';

class AddScreen extends StatefulWidget {
  final String payload;

  // late Reminder reminder;

  AddScreen({Key? key, this.payload = ''}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreen();
}

class _AddScreen extends State<AddScreen> {
  // model_notification.Notification notification ;
  bool _isLoading = false;
  Reminder reminder = Reminder('', '', '', null, null, null);
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("HH:mm:00");

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
    final ReminderHelper reminderHelper =
        Provider.of<ReminderHelper>(context, listen: false);

    int insertedReminderId = await reminderHelper.create(reminder);
    final startDate = reminder.startDate ?? DateTime.now();
    final daysToGenerate = reminder.endDate!.difference(startDate).inDays;
    for (var i = 0; i < daysToGenerate + 1; i++) {
      final date = dateFormat.format(startDate.add(Duration(days: i)));
      final dateTime = DateTime.parse(date + ' ' + (reminder.time ??= ''));
      // final date = dateFormat.format(startDate);
      // final dateTime = DateTime.parse(date + ' ' + (reminder.time ??= ''))
      //     .add(Duration(minutes: i));
      final notification = NotificationTable(insertedReminderId, dateTime);
      int insertedId = await NotificationHelper().create(notification);
      await NotificationService()
          .scheduleNotification(reminder, insertedId, dateTime);
    }

    setState(() {
      _isLoading = false;
    });

    Fluttertoast.showToast(
        msg: "添加成功",
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: Constant.toastFontSize);
    Navigator.pop(context);
  }

  Widget _body(context) {
    return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      _action(context),
      _name(context),
      _land(context),
      _startDate(context),
      _endDate(context),
      _time(context)
    ]);
  }

  Widget _action(context) {
    TextEditingController actionController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
        controller: actionController,
        style: const TextStyle(fontSize: Constant.textFormFontSize),
        onChanged: (value) {
          reminder.action = value;
        },
        decoration: const InputDecoration(
            hintText: '目的',
            hintStyle: TextStyle(fontSize: Constant.textFormFontSize),
            errorStyle: TextStyle(fontSize: Constant.textFormErrorFontSize)),
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
        style: const TextStyle(fontSize: Constant.textFormFontSize),
        onChanged: (value) {
          reminder.name = value;
        },
        decoration: const InputDecoration(
            hintText: '园主',
            hintStyle: TextStyle(fontSize: Constant.textFormFontSize),
            errorStyle: TextStyle(fontSize: Constant.textFormErrorFontSize)),
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
        style: const TextStyle(fontSize: Constant.textFormFontSize),
        onChanged: (value) {
          reminder.land = value;
        },
        decoration: const InputDecoration(
            hintText: '园地',
            hintStyle: TextStyle(fontSize: Constant.textFormFontSize),
            errorStyle: TextStyle(fontSize: Constant.textFormErrorFontSize)),
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

  Widget _startDate(context) {
    TextEditingController dateTimeController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
        controller: dateTimeController,
        style: const TextStyle(fontSize: Constant.textFormFontSize),
        decoration: const InputDecoration(
            hintText: '开始提醒日期',
            hintStyle: TextStyle(fontSize: Constant.textFormFontSize),
            errorStyle: TextStyle(fontSize: Constant.textFormErrorFontSize)),
        readOnly: true,
        onTap: () {
          DatePicker.showDatePicker(context,
              showTitleActions: true, onChanged: (date) {}, onConfirm: (date) {
            final dateOnly = dateFormat.format(date);
            reminder.startDate = DateTime.parse(dateOnly);
            dateTimeController.text = dateOnly;
          });
        },
        validator: _validateStartDate,
      )
    ]);
  }

  String? _validateStartDate(String? value) {
    if (value!.isEmpty) {
      return "请选择开始提醒日期";
    } else if (reminder.startDate!
        .isBefore(DateTime.parse(dateFormat.format(DateTime.now())))) {
      return "不能选择过去的日期";
    }
    return null;
  }

  Widget _endDate(context) {
    TextEditingController dateTimeController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
        controller: dateTimeController,
        style: const TextStyle(fontSize: Constant.textFormFontSize),
        decoration: const InputDecoration(
            hintText: '结束提醒日期',
            hintStyle: TextStyle(fontSize: Constant.textFormFontSize),
            errorStyle: TextStyle(fontSize: Constant.textFormErrorFontSize)),
        readOnly: true,
        onTap: () {
          DatePicker.showDatePicker(context,
              showTitleActions: true, onChanged: (date) {}, onConfirm: (date) {
            final dateOnly = dateFormat.format(date);
            reminder.endDate = DateTime.parse(dateOnly);
            dateTimeController.text = dateOnly;
          });
        },
        validator: _validateEndDate,
      )
    ]);
  }

  String? _validateEndDate(String? value) {
    if (value!.isEmpty) {
      return "请选择结束提醒日期";
    } else if (reminder.startDate == null) {
      return "请选择开始提醒日期";
    } else if (reminder.endDate!
        .isBefore(DateTime.parse(dateFormat.format(DateTime.now())))) {
      return "不能选择过去的日期";
    } else if (reminder.endDate!.isBefore(reminder.startDate!)) {
      return "结束日期不能早于开始日期";
    }
    return null;
  }

  Widget _time(context) {
    TextEditingController dateTimeController = TextEditingController();
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
        controller: dateTimeController,
        style: const TextStyle(fontSize: Constant.textFormFontSize),
        decoration: const InputDecoration(
            hintText: '提醒时间',
            hintStyle: TextStyle(fontSize: Constant.textFormFontSize),
            errorStyle: TextStyle(fontSize: Constant.textFormErrorFontSize)),
        readOnly: true,
        onTap: () {
          DatePicker.showTimePicker(context,
              showTitleActions: true,
              showSecondsColumn: false,
              onChanged: (date) {}, onConfirm: (date) {
            final timeOnly = timeFormat.format(date);
            reminder.time = timeOnly;
            dateTimeController.text = timeOnly;
          });
        },
        validator: _validateTime,
      )
    ]);
  }

  String? _validateTime(String? value) {
    if (value!.isEmpty) {
      return "请选择提醒时间";
    }
    return null;
  }
}
