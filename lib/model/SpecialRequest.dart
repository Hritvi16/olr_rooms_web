class SpecialRequest {
  String? srId;
  String? srName;

  SpecialRequest({
      String? srId, 
      String? srName
  });

  SpecialRequest.fromJson(dynamic json) {
    srId = json['sr_id'];
    srName = json['sr_name'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['sr_id'] = srId;
    map['sr_name'] = srName;
    return map;
  }

}