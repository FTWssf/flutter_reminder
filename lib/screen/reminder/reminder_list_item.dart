import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:oil_palm_system/database/reminder_helper.dart';
import 'package:oil_palm_system/model/reminder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:oil_palm_system/database/notification_helper.dart';
import 'package:oil_palm_system/model/notification_table.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/service/notification_service.dart';

class ReminderListItem extends StatefulWidget {
  const ReminderListItem({
    required this.reminder,
    required this.pagingController,
    Key? key,
  }) : super(key: key);

  final Reminder reminder;
  final PagingController pagingController;

  @override
  State<ReminderListItem> createState() => _ReminderListItemState();
}

class _ReminderListItemState extends State<ReminderListItem> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  void _cancelNotification(Reminder reminder) async {
    List<NotificationTable>? notifications =
        await NotificationHelper().getReminderNotification(reminder.id ?? 0);
    for (var notification in notifications!) {
      await NotificationService().cancelNotification(notification.id ?? 0);
    }
    reminder.cancelled = 1;
    ReminderHelper().update(reminder);

    Fluttertoast.showToast(
        msg: "取消成功",
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: Constant.toastFontSize);
    widget.pagingController.refresh();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '取消',
          color: (widget.reminder.cancelled == 1) ? Colors.grey : Colors.red,
          icon: Icons.cancel,
          onTap: () => {
            if (widget.reminder.cancelled == 0 ||
                widget.reminder.cancelled == null)
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
                                  _cancelNotification(widget.reminder)),
                        ],
                      );
                    })
              }
          },
        ),
      ],
      child: ListTile(
        title: Text(
          (widget.reminder.land ?? ''),
          style: TextStyle(
              fontSize: 24.0,
              color:
                  (widget.reminder.cancelled == 1) ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
        ),
        trailing: Text(
          dateFormat.format(widget.reminder.date ?? DateTime.now()) +
              '\n' +
              widget.reminder.time.toString(),
          style: const TextStyle(
            fontSize: 17.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
