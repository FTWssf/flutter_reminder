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
}
