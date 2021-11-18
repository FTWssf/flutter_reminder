class Reminder {
  static const String table = 'reminder';
  static const String colId = 'id';
  static const String colLandId = 'land_id';
  static const String colLand = 'land';
  static const String colDate = 'date';
  static const String colTime = 'time';
  static const String colCancelled = 'cancelled';

  // Structure
  int? _id;
  int? _landId;
  String? _land;
  DateTime? _date;
  String? _time;
  int? _cancelled;

  // Constructor
  Reminder(this._landId, this._date, this._time);

  // Getters
  int? get id => _id;
  int? get landId => _landId;
  String? get land => _land;
  DateTime? get date => _date;
  String? get time => _time;
  int? get cancelled => _cancelled;

  // Setters
  set date(DateTime? date) => {_date = date};
  set land(String? land) => {_land = land};
  set landId(int? landId) => {_landId = landId};
  set time(String? time) => {_time = time};
  set cancelled(int? cancelled) => {_cancelled = cancelled};

  // Map
  Reminder.fromMap(dynamic obj) {
    _id = obj[colId];
    _landId = obj[colLandId];
    _land = obj[colLand];
    _date = DateTime.parse(obj[colDate]);
    _time = obj[colTime];
    _cancelled = obj[colCancelled];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[colId] = _id;
    map[colLandId] = _landId;
    map[colDate] = _date!.toIso8601String();
    map[colTime] = _time;
    map[colCancelled] = _cancelled;

    return map;
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'age': age,
  //   };
  // }
}
