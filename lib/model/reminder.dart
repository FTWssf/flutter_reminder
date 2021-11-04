class Reminder {
  static const String table = 'reminder';
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colLand = 'land';
  static const String colAction = 'action';
  static const String colStartDate = 'start_date';
  static const String colEndDate = 'end_date';
  static const String colTime = 'time';
  static const String colCancelled = 'cancelled';

  // Structure
  int? _id;
  String? _name;
  String? _land;
  String? _action;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _time;
  int? _cancelled;

  // Constructor
  Reminder(this._name, this._land, this._action, this._startDate, this._endDate,
      this._time);

  // Getters
  int? get id => _id;
  String? get name => _name;
  String? get land => _land;
  String? get action => _action;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String? get time => _time;
  int? get cancelled => _cancelled;

  // Setters
  set name(String? name) => {_name = name};
  set land(String? land) => {_land = land};
  set action(String? action) => {_action = action};
  set startDate(DateTime? startDate) => {_startDate = startDate};
  set endDate(DateTime? endDate) => {_endDate = endDate};
  set time(String? time) => {_time = time};
  set cancelled(int? cancelled) => {_cancelled = cancelled};

  // Map
  Reminder.fromMap(dynamic obj) {
    _id = obj[colId];
    _name = obj[colName];
    _land = obj[colLand];
    _action = obj[colAction];
    _startDate = DateTime.parse(obj[colStartDate]);
    _endDate = DateTime.parse(obj[colEndDate]);
    _time = obj[colTime];
    _cancelled = obj[colCancelled];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[colId] = _id;
    map[colName] = _name;
    map[colLand] = _land;
    map[colAction] = _action;
    map[colStartDate] = _startDate!.toIso8601String();
    map[colEndDate] = _endDate!.toIso8601String();
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
