/// hi_id : "1"
/// hi_image : "hotels/1648114047.jpg"
/// it_id : "1"
/// it_type : "Room"

class ImageTitle {

  String? itId;
  String? itType;
  String? total;

  ImageTitle({
    String? itId,
    String? itType,
    String? total
  });

  ImageTitle.fromJson(dynamic json) {
    itId = json['it_id'];
    itType = json['it_type'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['it_id'] = itId;
    map['it_type'] = itType;
    map['total'] = total;
    return map;
  }

}