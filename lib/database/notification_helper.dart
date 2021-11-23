import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/model/notification_table.dart';

class NotificationHelper {
  Helper databaseHelper = Helper();

  Future<List<NotificationTable>?> read() async {
    final db = await databaseHelper.database;
    var objects =
        await db!.rawQuery('SELECT * FROM ${NotificationTable.table} ');

    List<NotificationTable>? notifications = objects.isNotEmpty
        ? objects.map((obj) => NotificationTable.fromMap(obj)).toList()
        : null;
    return notifications;
  }

  Future<NotificationTable?> fetch(int id) async {
    final db = await databaseHelper.database;
    var object = await db!.rawQuery(
        'SELECT * FROM ${NotificationTable.table} where ${NotificationTable.colId} = $id');
    NotificationTable? notification =
        object.isNotEmpty ? NotificationTable.fromMap(object[0]) : null;
    return notification;
  }

  Future<List<NotificationTable>?> getReminderNotification(int id) async {
    final db = await databaseHelper.database;
    var objects = await db!.rawQuery(
        'SELECT * FROM ${NotificationTable.table} where ${NotificationTable.colReminderId} = $id');

    List<NotificationTable>? notifications = objects.isNotEmpty
        ? objects.map((obj) => NotificationTable.fromMap(obj)).toList()
        : null;
    return notifications;
  }

  Future<int> create(NotificationTable notification) async {
    final db = await databaseHelper.database;
    int insertedId =
        await db!.insert(NotificationTable.table, notification.toMap());
    return insertedId;
  }

  Future<void> delete(int id) async {
    var db = await databaseHelper.database;
    db!.delete(
      NotificationTable.table,
      where: "${NotificationTable.colId} = ?",
      whereArgs: [id],
    );
  }
}
