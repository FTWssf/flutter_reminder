import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'package:oil_palm_system/database/reminder_helper.dart';
import 'package:oil_palm_system/database/notification_helper.dart';
import 'package:oil_palm_system/database/land_helper.dart';
import 'package:oil_palm_system/model/reminder.dart';
import 'package:oil_palm_system/model/land.dart';
import 'package:oil_palm_system/model/notification_table.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/service/notification_service.dart';

class ReminderAddScreen extends StatefulWidget {
  const ReminderAddScreen({Key? key, required this.pagingController})
      : super(key: key);
  final PagingController pagingController;
  @override
  State<ReminderAddScreen> createState() => _ReminderAddScreenState();
}

class _ReminderAddScreenState extends State<ReminderAddScreen> {
  bool _isLoading = false;
  Reminder reminder = Reminder(null, null, '');
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("HH:mm:00");
  List<Land>? lands;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    LandHelper().read().then((value) => {lands = value});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Scaffold(
          // key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('添加'),
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

    if (!_formkey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    int insertedReminderId = await ReminderHelper().create(reminder);
    final dateTime = DateTime.parse(
        dateFormat.format(reminder.date!) + ' ' + (reminder.time ??= ''));
    final notification = NotificationTable(insertedReminderId, dateTime);

    int insertedId = await NotificationHelper().create(notification);
    await NotificationService()
        .scheduleNotification(reminder, insertedId, dateTime);

    setState(() {
      _isLoading = false;
    });

    Fluttertoast.showToast(
        msg: "添加成功",
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: Constant.toastFontSize);
    widget.pagingController.refresh();
    Navigator.pop(context);
  }

  Widget _body(context) {
    return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      _land(context),
      _startDate(context),
      _time(context)
    ]);
  }

  Widget _land(context) {
    TextEditingController landController = TextEditingController();

    return Column(mainAxisSize: MainAxisSize.max, children: [
      TextFormField(
          controller: landController,
          style: const TextStyle(fontSize: Constant.textFormFontSize),
          onChanged: (value) {
            // reminder.land = value;
          },
          decoration: const InputDecoration(
              hintText: '园地',
              hintStyle: TextStyle(fontSize: Constant.textFormFontSize),
              errorStyle: TextStyle(fontSize: Constant.textFormErrorFontSize)),
          validator: _validateLand,
          readOnly: true,
          onTap: () async {
            if (lands == null) {
              return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(title: Text("请先添加园地"));
                  });
            }
            await Picker(
                cancelTextStyle:
                    const TextStyle(color: Colors.black54, fontSize: 16),
                confirmTextStyle:
                    const TextStyle(color: Colors.blue, fontSize: 16),
                height: 240.0,
                // headerDecoration: const Decoration(),
                itemExtent: 42.0,
                cancelText: '取消',
                confirmText: '确定',
                adapter: PickerDataAdapter<String>(
                    pickerdata: lands!.map((land) => land.name).toList()),
                textAlign: TextAlign.left,
                columnPadding: const EdgeInsets.all(8.0),
                delimiter: null,
                onConfirm: (Picker picker, List value) {
                  landController.text = picker.getSelectedValues().first;
                  reminder.land = picker.getSelectedValues().first;
                  reminder.landId = lands!.elementAt(value.first).id;
                  // lands!.elementAt(value.first).name
                }).showModal(this.context);

            // picker.show(_scaffoldKey.currentState ?? Scaffold.of(context));
          })
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
              locale: LocaleType.zh,
              showTitleActions: true,
              onChanged: (date) {}, onConfirm: (date) {
            final dateOnly = dateFormat.format(date);
            reminder.date = DateTime.parse(dateOnly);
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
    } else if (reminder.date!
        .isBefore(DateTime.parse(dateFormat.format(DateTime.now())))) {
      return "不能选择过去的日期";
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
              locale: LocaleType.zh,
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
