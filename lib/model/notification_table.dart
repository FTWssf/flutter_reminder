class NotificationTable {
  static const String table = 'notification';
  static const String colId = 'id';
  static const String colReminderId = 'reminder_id';
  static const String colDate = 'date';

  // Structure
  int? _id;
  int? _reminderId;
  DateTime? _date;

  // Constructor
  NotificationTable(this._reminderId, this._date);

  // Getters
  int? get id => _id;
  int? get reminderId => _reminderId;
  DateTime? get date => _date;

  // Setters
  set reminderId(int? reminderId) => {_reminderId = reminderId};
  set date(DateTime? date) => {_date = date};

  // Map
  NotificationTable.fromMap(dynamic obj) {
    _id = obj[colId];
    _reminderId = obj[colReminderId];
    _date = DateTime.parse(obj[colDate]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[colId] = _id;
    map[colReminderId] = _reminderId;
    map[colDate] = _date!.toIso8601String();
    return map;
  }
}
