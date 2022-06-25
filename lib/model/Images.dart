/// hi_id : "1"
/// hi_image : "hotels/1648114047.jpg"
/// it_id : "1"
/// it_type : "Room"

class Images {

  String? hiId;
  String? hiImage;
  String? itId;
  String? itType;
  String? catId;
  String? catName;

  Images({
      String? hiId, 
      String? hiImage, 
      String? itId, 
      String? itType,
      String? catId,
      String? catName,});

  Images.fromJson(dynamic json) {
    hiId = json!=null ? json['hi_id'] : "";
    hiImage = json!=null ? json['hi_image'] : "";
    itId = json!=null ? json['it_id'] : "";
    itType = json!=null ? json['it_type'] : "";
    catId = json!=null ? json['cat_id'] : "";
    catName = json!=null ? json['cat_name'] : "";
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hi_id'] = hiId;
    map['hi_image'] = hiImage;
    map['it_id'] = itId;
    map['it_type'] = itType;
    map['cat_id'] = catId;
    map['cat_name'] = catName;
    return map;
  }

}