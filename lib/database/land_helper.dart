import 'package:oil_palm_system/model/land.dart';
import 'package:oil_palm_system/database/helper.dart';
import 'package:oil_palm_system/res/constant.dart';

class LandHelper {
  Helper databaseHelper = Helper();
  static const row = Constant.row;

  Future<List<Land>?> read() async {
    final db = await databaseHelper.database;
    var objects =
        await db!.rawQuery('SELECT * FROM ${Land.table} ORDER BY name');
    List<Land>? lands = objects.isNotEmpty
        ? objects.map((obj) => Land.fromMap(obj)).toList()
        : null;
    return lands;
  }

  Future<List<Land>?> readPagination(int page) async {
    final offset = (page - 1) * row;
    final db = await databaseHelper.database;
    var objects = await db!.rawQuery(
        'SELECT * FROM ${Land.table} ORDER BY name LIMIT $offset, $row');
    List<Land>? lands = objects.isNotEmpty
        ? objects.map((obj) => Land.fromMap(obj)).toList()
        : null;
    return lands;
  }

  Future<int> create(Land land) async {
    final db = await databaseHelper.database;
    int insertedId = await db!.insert(Land.table, land.toMap());
    return insertedId;
  }

  Future<void> update(Land land) async {
    final db = await databaseHelper.database;
    await db!.update(Land.table, land.toMap(),
        where: '${Land.colId} = ?', whereArgs: [land.id]);
  }

  Future<void> delete(int id) async {
    var db = await databaseHelper.database;
    db!.delete(
      Land.table,
      where: "${Land.colId} = ?",
      whereArgs: [id],
    );
  }
}
