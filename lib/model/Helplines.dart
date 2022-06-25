class Helplines {
  String? saId;
  String? saCc;
  String? saMobile;
  String? saName;
  String? stType;
  String? cName;

  Helplines({
      String? saId, 
      String? saCc,
      String? saMobile,
      String? saName,
      String? stType,
      String? cName
  });

  Helplines.fromJson(dynamic json) {
    saId = json['sa_id'];
    saCc = json['sa_cc'];
    saMobile = json['sa_mobile'];
    saName = json['sa_name'];
    stType = json['st_type'];
    cName = json['c_name'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sa_id'] = saId;
    map['sa_cc'] = saCc;
    map['sa_mobile'] = saMobile;
    map['sa_name'] = saName;
    map['st_type'] = stType;
    map['c_name'] = cName;
    return map;
  }

}