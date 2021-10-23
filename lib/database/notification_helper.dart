import 'package:oil_palm_system/model/notification.dart';
import 'package:oil_palm_system/database/helper.dart';

class NotificationHelper {
  Helper databaseHelper = Helper();

  Future<List<Notification>?> read() async {
    final db = await databaseHelper.database;
    var objects = await db!.rawQuery('SELECT * FROM ${Notification.table} '
        'ORDER BY Id desc');

    List<Notification>? notifications = objects.isNotEmpty
        ? objects.map((obj) => Notification.fromMap(obj)).toList()
        : null;
    return notifications;
  }

  Future<void> create(Notification notification) async {
    final db = await databaseHelper.database;
    await db!.insert(Notification.table, notification.toMap());
  }

  Future<void> update(Notification notification) async {
    final db = await databaseHelper.database;
    await db!.update(Notification.table, notification.toMap(),
        where: '${Notification.colId} = ?', whereArgs: [notification.id]);
  }

  Future<void> delete(int id) async {
    var db = await databaseHelper.database;
    db!.delete(
      Notification.table,
      where: "${Notification.colId} = ?",
      whereArgs: [id],
    );
  }
}