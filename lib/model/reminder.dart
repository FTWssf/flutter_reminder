class Reminder {
  static const String table = 'Reminder';
  static const String colId = 'Id';
  static const String colName = 'Name';
  static const String colLand = 'Land';
  static const String colAction = 'Action';
  static const String colDatetime = 'Datetime';

  // Structure
  int? _id;
  String? _name;
  String? _land;
  String? _action;
  DateTime? _datetime;

  // Constructor
  Reminder(this._name, this._land, this._action, this._datetime);

  // Getters
  int? get id => _id;
  String? get name => _name;
  String? get land => _land;
  String? get action => _action;
  DateTime? get datetime => _datetime;

  // Setters
  set name(String? name) => {_name = name};
  set land(String? land) => {_land = land};
  set action(String? action) => {_action = action};
  set datetime(DateTime? datetime) => {_datetime = datetime};

  // Map
  Reminder.fromMap(dynamic obj) {
    _id = obj[colId];
    _name = obj[colName];
    _land = obj[colLand];
    _action = obj[colAction];
    _datetime = DateTime.parse(obj[colDatetime]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[colId] = _id;
    map[colName] = _name;
    map[colLand] = _land;
    map[colAction] = _action;
    map[colDatetime] = _datetime!.toIso8601String();
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
