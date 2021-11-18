class Land {
  static const String table = 'land';
  static const String colId = 'id';
  static const String colName = 'name';

  // Structure
  int? _id;
  String? _name;

  // Constructor
  Land(this._name);

  // Getters
  int? get id => _id;
  String? get name => _name;

  // Setters
  set name(String? name) => {_name = name};

  // Map
  Land.fromMap(dynamic obj) {
    _id = obj[colId];
    _name = obj[colName];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[colId] = _id;
    map[colName] = _name;
    return map;
  }
}
