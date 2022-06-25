class States {
  String? sId;
  String? sName;
  String? coId;

  States({
      String? sId,
      String? sName,
      String? coId,});

  States.fromJson(dynamic json) {
    sId = json['s_id'];
    sName = json['s_name'];
    coId = json['co_id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['s_id'] = sId;
    map['s_name'] = sName;
    map['co_id'] = coId;
    return map;
  }

}