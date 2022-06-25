class TimePeriod {
  String? tpId;
  String? tp3;
  String? tp6;
  String? tp12;
  String? tp24;
  String? hId;

  TimePeriod({
      String? tpId, 
      String? tp3, 
      String? tp6, 
      String? tp12, 
      String? tp24, 
      String? hId,});

  TimePeriod.fromJson(dynamic json) {
    tpId = json['tp_id'];
    tp3 = json['tp_3'];
    tp6 = json['tp_6'];
    tp12 = json['tp_12'];
    tp24 = json['tp_24'];
    hId = json['h_id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tp_id'] = tpId;
    map['tp_3'] = tp3;
    map['tp_6'] = tp6;
    map['tp_12'] = tp12;
    map['tp_24'] = tp24;
    map['h_id'] = hId;
    return map;
  }

}