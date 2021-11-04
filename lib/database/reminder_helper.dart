import 'package:flutter/foundation.dart';
import 'package:oil_palm_system/model/reminder.dart';
import 'package:oil_palm_system/database/helper.dart';

class ReminderHelper with ChangeNotifier {
  Helper databaseHelper = Helper();
  List<Reminder>? items = [];

  ReminderHelper() {
    read();
  }

  //Future<List<Notification>?>
  void read() async {
    final db = await databaseHelper.database;
    var objects = await db!.rawQuery(
        'SELECT *, (CASE WHEN cancelled == 1 THEN 1 WHEN end_date < (date("now", "localtime")||"T00:00:00.000") THEN 1 ELSE 0 END) as cancelled FROM ${Reminder.table} '
        'ORDER BY 9 asc, start_date asc');
    List<Reminder>? reminders = objects.isNotEmpty
        ? objects.map((obj) => Reminder.fromMap(obj)).toList()
        : null;
    items = reminders;
    notifyListeners();
    // return notifications;
  }

  Future<int> create(Reminder reminder) async {
    final db = await databaseHelper.database;
    int insertedId = await db!.insert(Reminder.table, reminder.toMap());
    read();
    return insertedId;
  }

  Future<void> update(Reminder reminder) async {
    final db = await databaseHelper.database;
    await db!.update(Reminder.table, reminder.toMap(),
        where: '${Reminder.colId} = ?', whereArgs: [reminder.id]);
    read();
  }

  Future<void> delete(int id) async {
    var db = await databaseHelper.database;
    db!.delete(
      Reminder.table,
      where: "${Reminder.colId} = ?",
      whereArgs: [id],
    );
  }
}
