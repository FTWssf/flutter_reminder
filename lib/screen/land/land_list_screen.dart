import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:oil_palm_system/model/land.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'package:oil_palm_system/database/reminder_helper.dart';
import 'package:oil_palm_system/database/land_helper.dart';
import 'package:oil_palm_system/database/notification_helper.dart';
import 'package:oil_palm_system/model/notification_table.dart';
import 'package:oil_palm_system/model/reminder.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/service/notification_service.dart';

class LandListScreen extends StatefulWidget {
  const LandListScreen({Key? key}) : super(key: key);

  @override
  State<LandListScreen> createState() => _LandListScreenState();
}

class _LandListScreenState extends State<LandListScreen> {
  final _pagingController = PagingController<int, Land>(firstPageKey: 1);
  Land land = Land('');
  bool _isLoading = false;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newPage = await LandHelper().readPagination(pageKey);

      bool isLastPage = false;
      final newItems = newPage ?? [];
      if (newPage == null) {
        isLastPage = true;
      } else {
        isLastPage = newPage.length < LandHelper.row;
      }

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _deleteLand(Land land) async {
    List<Reminder>? reminders =
        await ReminderHelper().getLandReminder(land.id ?? 0);
    if (reminders != null) {
      for (var reminder in reminders) {
        List<NotificationTable>? notifications = await NotificationHelper()
            .getReminderNotification(reminder.id ?? 0);
        if (notifications != null) {
          for (var notification in notifications) {
            await NotificationService()
                .cancelNotification(notification.id ?? 0);
            NotificationHelper().delete(notification.id ?? 0);
          }
        }
        ReminderHelper().delete(reminder.id ?? 0);
      }
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    LandHelper().delete(land.id ?? 0);

    setState(() {
      _isLoading = false;
    });

    _pagingController.refresh();
    Fluttertoast.showToast(
        msg: "删除成功",
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: Constant.toastFontSize);
    Navigator.pop(context);
  }

  Future<void> _addLand() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await LandHelper().create(land);

    setState(() {
      _isLoading = false;
    });

    _pagingController.refresh();
    Fluttertoast.showToast(
        msg: "添加成功",
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: Constant.toastFontSize);

    Navigator.pop(context);
  }

  Widget _land(context) {
    TextEditingController landController = TextEditingController();
    return Form(
        key: _formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: TextFormField(
          enableSuggestions: false,
          controller: landController,
          style: const TextStyle(fontSize: Constant.textFormFontSize),
          onChanged: (value) {
            land.name = value;
          },
          decoration: const InputDecoration(
              hintText: '园地',
              hintStyle: TextStyle(fontSize: Constant.textFormFontSize),
              errorStyle: TextStyle(fontSize: Constant.textFormErrorFontSize)),
          validator: _validateLand,
        ));
  }

  Widget _landListItem(Land land) {
    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '取消',
          color: Colors.red,
          icon: Icons.cancel,
          onTap: () => {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:
                        const Text("注意", style: TextStyle(color: Colors.red)),
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
                          onPressed: () => {_deleteLand(land)})
                    ],
                  );
                })
          },
        ),
      ],
      child: ListTile(
        title: Text(
          land.name ?? '',
          style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String? _validateLand(String? value) {
    if (value!.isEmpty) {
      return "请输入园地";
    } else if (value.length > 50) {
      return "园地不能多过50个数字";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
          isLoading: _isLoading,
          child: RefreshIndicator(
            onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
            ),
            child: PagedListView.separated(
              pagingController: _pagingController,
              separatorBuilder: (context, index) => const Divider(
                thickness: 1,
              ),
              builderDelegate: PagedChildBuilderDelegate<Land>(
                itemBuilder: (context, item, index) => _landListItem(item),
                firstPageErrorIndicatorBuilder: (context) => const ListTile(
                    title: Text('没有数据',
                        style: TextStyle(fontSize: 25.0),
                        textAlign: TextAlign.center)),
                noItemsFoundIndicatorBuilder: (context) => const ListTile(
                  title: Text('没有数据',
                      style: TextStyle(fontSize: 25.0),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("添加园地"),
                  content: _land(context),
                  actions: [
                    TextButton(
                      child: const Text("返回"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                        child: const Text("确认"), onPressed: () => _addLand()),
                  ],
                );
              });
        },
        tooltip: '添加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
