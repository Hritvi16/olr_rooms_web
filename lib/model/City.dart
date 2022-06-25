class City {
  String? cId;
  String? cName;
  String? sId;
  String? pcImage;

  City({
      String? cId, 
      String? cName, 
      String? sId,
      String? pcImage,
  });

  City.fromJson(dynamic json) {
    cId = json['c_id'];
    cName = json['c_name'];
    sId = json['s_id'];
    pcImage = json['pc_image'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['c_id'] = cId;
    map['c_name'] = cName;
    map['s_id'] = sId;
    map['pc_image'] = pcImage;
    return map;
  }

}