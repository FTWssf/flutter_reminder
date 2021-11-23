import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:oil_palm_system/database/reminder_helper.dart';
import 'package:oil_palm_system/model/reminder.dart';
import 'package:oil_palm_system/screen/reminder/reminder_add_screen.dart';
import 'package:oil_palm_system/screen/reminder/reminder_list_item.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({Key? key}) : super(key: key);

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd"); //HH:mm
  final _pagingController = PagingController<int, Reminder>(firstPageKey: 1);

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
      final newPage = await ReminderHelper().readPagination(pageKey);
      // final count = await ReminderHelper().count();
      // final computedCount =
      //     count > ReminderHelper.row ? count - ReminderHelper.row : 0;
      // final previouslyFetchedItemsCount =
      //     _pagingController.itemList?.length ?? 0;
      // final isLastPage = previouslyFetchedItemsCount >= computedCount;
      bool isLastPage = false;
      final newItems = newPage ?? [];
      if (newPage == null) {
        isLastPage = true;
      } else {
        isLastPage = newPage.length < ReminderHelper.row;
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

  // void _routeAddScreen(ReminderHelper reminderHelper) async {
  //   Navigator.push<void>(
  //     context,
  //     MaterialPageRoute<void>(
  //       builder: (context) => ListenableProvider<ReminderHelper>.value(
  //         value: reminderHelper,
  //          child: const ReminderAddScreen(),
  //       ),
  //     ),
  //   );
  // }

  void _routeAddScreen() async {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) =>
            ReminderAddScreen(pagingController: _pagingController),
      ),
    );
  }

  // void _cancelNotification(
  //     Reminder reminder, ReminderHelper reminderHelper) async {
  //   List<NotificationTable>? notifications =
  //       await NotificationHelper().getReminderNotification(reminder.id ?? 0);
  //   for (var notification in notifications!) {
  //     await NotificationService().cancelNotification(notification.id ?? 0);
  //   }
  //   reminder.cancelled = 1;
  //   reminderHelper.update(reminder);

  //   Fluttertoast.showToast(
  //       msg: "取消成功",
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.green,
  //       textColor: Colors.white,
  //       fontSize: Constant.toastFontSize);
  //   Navigator.pop(context);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedListView.separated(
          pagingController: _pagingController,
          // padding: const EdgeInsets.all(16),
          separatorBuilder: (context, index) => const Divider(
            thickness: 1,
          ),
          builderDelegate: PagedChildBuilderDelegate<Reminder>(
            itemBuilder: (context, item, index) => ReminderListItem(
              reminder: item,
              pagingController: _pagingController,
            ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _routeAddScreen();
        },
        tooltip: '添加',
        child: const Icon(Icons.add),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return ChangeNotifierProvider(
  //     create: (context) => ReminderHelper(),
  //     child: Consumer<ReminderHelper>(
  //       builder: (context, reminderHelper, child) => Scaffold(
  //         body: ListView.separated(
  //           itemCount: (reminderHelper.items == null
  //               ? 0
  //               : reminderHelper.items!.length),
  //           itemBuilder: (context, index) {
  //             final item = reminderHelper.items?[index];

  //             return Slidable(
  //               actionPane: const SlidableDrawerActionPane(),
  //               secondaryActions: <Widget>[
  //                 IconSlideAction(
  //                   caption: '取消',
  //                   color: (item!.cancelled == 1) ? Colors.grey : Colors.red,
  //                   icon: Icons.cancel,
  //                   onTap: () => {
  //                     if (item.cancelled == 0)
  //                       {
  //                         showDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                               return AlertDialog(
  //                                 title: const Text("注意"),
  //                                 content: const Text("取消此通知？"),
  //                                 actions: [
  //                                   TextButton(
  //                                     child: const Text("返回"),
  //                                     onPressed: () {
  //                                       Navigator.pop(context);
  //                                     },
  //                                   ),
  //                                   TextButton(
  //                                       child: const Text("确认"),
  //                                       onPressed: () =>
  //                                           {} //_cancelNotification(item, reminderHelper),
  //                                       ),
  //                                 ],
  //                               );
  //                             })
  //                       }
  //                   },
  //                 ),
  //               ],
  //               child: ListTile(
  //                 title: Text(
  //                   item.action ?? '',
  //                   style: TextStyle(
  //                       fontSize: 24.0,
  //                       color:
  //                           (item.cancelled == 1) ? Colors.red : Colors.green,
  //                       fontWeight: FontWeight.bold,
  //                       decoration: TextDecoration.underline),
  //                 ),
  //                 subtitle: Padding(
  //                   padding: const EdgeInsets.only(top: 3.5),
  //                   child: Text(
  //                     '园主: ' + (item.name ?? '') + '\n园地: ' + (item.land ?? ''),
  //                     style: const TextStyle(
  //                       fontSize: 21.0,
  //                       color: Colors.black,
  //                     ),
  //                   ),
  //                 ),
  //                 isThreeLine: true,
  //                 trailing: Text(
  //                   dateFormat.format(item.startDate ?? DateTime.now()) +
  //                       '\n' +
  //                       dateFormat.format(item.endDate ?? DateTime.now()) +
  //                       '\n' +
  //                       item.time.toString(),
  //                   style: const TextStyle(
  //                     fontSize: 17.0,
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //           separatorBuilder: (context, index) {
  //             return const Divider(
  //               thickness: 1,
  //             );
  //           },
  //         ),
  //         floatingActionButton: FloatingActionButton(
  //           onPressed: () {
  //             _routeAddScreen(reminderHelper);
  //           },
  //           tooltip: '添加',
  //           child: const Icon(Icons.add),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
