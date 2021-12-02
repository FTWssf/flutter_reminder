import 'package:flutter/foundation.dart';
import 'package:oil_palm_system/model/notification_table.dart';
import 'package:sqflite/sqflite.dart';

import 'package:oil_palm_system/model/reminder.dart';
import 'package:oil_palm_system/model/land.dart';
import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/res/constant.dart';

class ReminderHelper with ChangeNotifier {
  Helper databaseHelper = Helper();
  List<Reminder>? items = [];
  static const row = Constant.row;

  void read() async {
    final db = await databaseHelper.database;
    var objects = await db!.rawQuery('SELECT * FROM ${Reminder.table} '
        'ORDER BY cancelled asc, date asc');
    List<Reminder>? reminders = objects.isNotEmpty
        ? objects.map((obj) => Reminder.fromMap(obj)).toList()
        : null;
    items = reminders;
    notifyListeners();
  }

  Future<List<Reminder>?> readPagination(int page) async {
    final offset = (page - 1) * row;
    final db = await databaseHelper.database;
    var objects = await db!.rawQuery(
        'SELECT *, (SELECT name FROM ${Land.table} where id = ${Reminder.table}.${Reminder.colLandId}) as land FROM ${Reminder.table} '
        'ORDER BY cancelled asc, date asc LIMIT $offset, $row');

    List<Reminder>? reminders = objects.isNotEmpty
        ? objects.map((obj) => Reminder.fromMap(obj)).toList()
        : null;

    return reminders;
  }

  Future<int> count() async {
    final db = await databaseHelper.database;
    int count = Sqflite.firstIntValue(
            await db!.rawQuery('SELECT COUNT(*) FROM ${Reminder.table}')) ??
        0;
    return count;
  }

  Future<List<Reminder>?> getLandReminder(int id) async {
    final db = await databaseHelper.database;
    var objects = await db!.rawQuery(
        'SELECT * FROM ${Reminder.table} where ${Reminder.colLandId} = $id');

    List<Reminder>? reminders = objects.isNotEmpty
        ? objects.map((obj) => Reminder.fromMap(obj)).toList()
        : null;
    return reminders;
  }

  Future<List<Reminder>?> getPeriodicReminder() async {
    final db = await databaseHelper.database;
    var objects = await db!.rawQuery(
        'SELECT *, (SELECT name FROM ${Land.table} where id = ${Reminder.table}.${Reminder.colLandId}) as land, (SELECT date from ${NotificationTable.table} where ${NotificationTable.colReminderId} = ${Reminder.table}.${Reminder.colId} and date = (date("now", "+1 day")||"T"||time||".000") limit 1) as notification FROM ${Reminder.table} where cancelled = 0 and date <= (date("now", "localtime")||"T00:00:00.000") and notification IS NULL;');
    // for (var a in objects) {
    //   print('periodicReminder: $a');
    // }
    List<Reminder>? reminders = objects.isNotEmpty
        ? objects.map((obj) => Reminder.fromMap(obj)).toList()
        : null;

    return reminders;
  }

  Future<int> create(Reminder reminder) async {
    reminder.cancelled = 0;
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
