/// ca_id : "7"
/// id : "12"
/// name : "Jacuzzi"
/// am_image : "icons/1648288294.png"

class SearchDetails {
  String? id;
  String? name;
  
  SearchDetails({
      String? id,
      String? name
  });

  SearchDetails.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    return map;
  }

}