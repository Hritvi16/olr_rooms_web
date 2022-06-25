/// ca_id : "7"
/// am_id : "12"
/// am_name : "Jacuzzi"
/// am_image : "icons/1648288294.png"

class Amenities {
  String? haId;
  String? caId;
  String? amId;
  String? amName;
  String? amImage;
  
  Amenities({
      String? haId,
      String? caId,
      String? amId,
      String? amName, 
      String? amImage,});

  Amenities.fromJson(dynamic json) {
    haId = json['ha_id'];
    caId = json['ca_id'];
    amId = json['am_id'];
    amName = json['am_name'];
    amImage = json['am_image'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ha_id'] = haId;
    map['ca_id'] = caId;
    map['am_id'] = amId;
    map['am_name'] = amName;
    map['am_image'] = amImage;
    return map;
  }

}