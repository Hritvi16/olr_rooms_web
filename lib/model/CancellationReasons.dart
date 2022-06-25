class CancellationReasons {
  String? crId;
  String? crName;

  CancellationReasons(
    String? crId,
    String? crName
  );

  CancellationReasons.fromJson(Map<String, dynamic> json){
    crId = json['cr_id'];
    crName = json['cr_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();

    map['cr_id'] = crId;
    map['cr_name'] = crName;

    return map;
  }
}