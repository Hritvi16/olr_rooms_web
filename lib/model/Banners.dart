/// ban_id : "1"
/// ban_image : "banners/1647415255.jpg"
/// h_id : null

class Banners {
  String? banId;
  String? banImage;
  String? hId;

  Banners({
      String? banId, 
      String? banImage, 
      String? hId
  });

  Banners.fromJson(dynamic json) {
    banId = json['ban_id'];
    banImage = json['ban_image'];
    hId = json['h_id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ban_id'] = banId;
    map['ban_image'] = banImage;
    map['h_id'] = hId;
    return map;
  }

}