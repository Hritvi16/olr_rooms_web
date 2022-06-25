class HO {
  String? hoId;
  String? hoName;
  String? hoAddress;
  String? hoPincode;
  String? hoLandmark;
  String? hoNumber;
  String? hoEmail;
  String? hoLat;
  String? hoLong;
  String? coId;
  String? sId;
  String? cId;
  String? arId;
  String? isDelete;

  HO({
      String? hoId,
      String? hoName,
      String? hoAddress,
      String? hoPincode,
      String? hoLandmark,
      String? hoNumber,
      String? hoEmail,
      String? hoLat,
      String? hoLong,
      String? coId, 
      String? sId, 
      String? cId, 
      String? arId,
      String? isDelete,
  });

  HO.fromJson(dynamic json) {
    hoId = json['ho_id'];
    hoName = json['ho_name'];
    hoAddress = json['ho_address'];
    hoPincode = json['ho_pincode'];
    hoLandmark = json['ho_landmark'];
    hoNumber = json['ho_number'];
    hoEmail = json['ho_email'];
    hoLat = json['ho_lat'];
    hoLong = json['ho_long'];
    coId = json['co_id'];
    sId = json['s_id'];
    cId = json['c_id'];
    arId = json['ar_id'];
    isDelete = json['is_delete'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ho_id'] = hoId;
    map['ho_name'] = hoName;
    map['ho_address'] = hoAddress;
    map['ho_pincode'] = hoPincode;
    map['ho_landmark'] = hoLandmark;
    map['ho_number'] = hoNumber;
    map['ho_email'] = hoEmail;
    map['ho_lat'] = hoLat;
    map['ho_long'] = hoLong;
    map['co_id'] = coId;
    map['s_id'] = sId;
    map['c_id'] = cId;
    map['ar_id'] = arId;
    map['is_delete'] = isDelete;
    return map;
  }

}