class RequestTypes {
  String? rtId;
  String? rtType;
  String? rtMessage;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;
  String? isDelete;

  RequestTypes({
      String? rtId, 
      String? rtType, 
      String? rtMessage, 
      String? createdAt, 
      String? createdBy, 
      String? updatedAt, 
      String? updatedBy, 
      String? isDelete,});

  RequestTypes.fromJson(dynamic json) {
    rtId = json['rt_id'];
    rtType = json['rt_type'];
    rtMessage = json['rt_message'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
    isDelete = json['is_delete'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rt_id'] = rtId;
    map['rt_type'] = rtType;
    map['rt_message'] = rtMessage;
    map['created_at'] = createdAt;
    map['created_by'] = createdBy;
    map['updated_at'] = updatedAt;
    map['updated_by'] = updatedBy;
    map['is_delete'] = isDelete;
    return map;
  }

}