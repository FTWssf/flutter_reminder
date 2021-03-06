import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:oil_palm_system/res/constant.dart';
import 'package:oil_palm_system/model/reminder.dart';
import 'package:oil_palm_system/model/notification_table.dart';
import 'package:oil_palm_system/model/land.dart';

class Helper {
  static const dbFileName = Constant.dbFileName;
  static const dbCurrentVersion = Constant.dbCurrentVersion;

  static final Helper instance = Helper.internal();
  static Database? _database;

  Helper.internal();

  factory Helper() {
    return instance;
  }

  Future<Database?> get database async {
    return _database ??= await initializeDatabase();
  }

  Future<Database> initializeDatabase() async {
    // Directory applicationDocumentDirectory =
    //     await getApplicationDocumentsDirectory();
    // String path = join(applicationDocumentDirectory.path, dbFileName);

    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbFileName);
    var todosDatabase = await openDatabase(path,
        version: dbCurrentVersion, onCreate: _createTable);
    return todosDatabase;
  }

  Future close() async {
    final db = await instance.database;
    db!.close();
  }

  void deleteDb() async {
    // Directory applicationDocumentDirectory =
    //     await getApplicationDocumentsDirectory();
    // String path = join(applicationDocumentDirectory.path, dbFileName);
    // await deleteDatabase(path);
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, dbFileName);
    await deleteDatabase(path);
  }

  void createTable() async {
    final db = await instance.database;
    await db!.execute('CREATE TABLE ${Reminder.table} ( '
        '${Reminder.colId} INTEGER PRIMARY KEY AUTOINCREMENT, '
        '${Reminder.colLandId} TEXT, '
        '${Reminder.colDate} TEXT, '
        '${Reminder.colTime} TEXT, ');
  }

  void _createTable(Database db, int newVersion) async {
    // await db.execute('DROP TABLE IF EXISTS ${Reminder.table}');
    // await db.execute('DROP TABLE IF EXISTS ${NotificationTable.table}');
    await db.execute('CREATE TABLE ${Reminder.table} ( '
        '${Reminder.colId} INTEGER PRIMARY KEY AUTOINCREMENT, '
        '${Reminder.colLandId} INTEGER NOT NULL, '
        '${Reminder.colDate} TEXT, '
        '${Reminder.colTime} TEXT, '
        '${Reminder.colCancelled} INTEGER DEFAULT 0, '
        'FOREIGN KEY (${Reminder.colLandId}) REFERENCES ${Land.table} (${Land.colId}))');

    await db.execute('CREATE TABLE ${NotificationTable.table} ( '
        '${NotificationTable.colId} INTEGER PRIMARY KEY AUTOINCREMENT, '
        '${NotificationTable.colReminderId} INTEGER NOT NULL, '
        '${NotificationTable.colDate} TEXT, '
        'FOREIGN KEY (${NotificationTable.colReminderId}) REFERENCES ${Reminder.table} (${Reminder.colId}))');

    await db.execute('CREATE TABLE ${Land.table} ( '
        '${Land.colId} INTEGER PRIMARY KEY AUTOINCREMENT, '
        '${Land.colName} TEXT NOT NULL)');
  }

  void deleteTable() async {
    final db = await instance.database;
    await db!.execute('DROP TABLE IF EXISTS ${Reminder.table}');
    await db.execute('DROP TABLE IF EXISTS ${NotificationTable.table}');
  }
}
