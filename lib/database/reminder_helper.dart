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
    var objects = await db!.rawQuery('SELECT * FROM ${Reminder.table} '
        'ORDER BY Id desc');

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
