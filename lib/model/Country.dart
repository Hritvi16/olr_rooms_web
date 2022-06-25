/// co_id : "2"
/// co_name : "India"

class Country {
  String? coId;
  String? coName;

  Country({
      String? coId, 
      String? coName,});

  Country.fromJson(dynamic json) {
    coId = json['co_id'];
    coName = json['co_name'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['co_id'] = coId;
    map['co_name'] = coName;
    return map;
  }

}