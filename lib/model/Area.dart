class Area {
  String? arId;
  String? arName;
  String? cId;

  Area({
      String? arId, 
      String? arName, 
      String? cId,
  });

  Area.fromJson(dynamic json) {
    arId = json['ar_id'];
    arName = json['ar_name'];
    cId = json['s_id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ar_id'] = arId;
    map['ar_name'] = arName;
    map['s_id'] = cId;
    return map;
  }

}