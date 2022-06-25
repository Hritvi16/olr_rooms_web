/// hn_id : "1"
/// hn_place : "Nearby/1647415255.jpg"
/// h_id : null

class Nearby {
  String? hnId;
  String? hnPlace;
  String? hnLat;
  String? hnLong;
  String? hnDistance;
  String? hId;

  Nearby({
      String? hnId, 
      String? hnPlace, 
      String? hnLat,
      String? hnLong,
      String? hnDistance,
      String? hId
  });

  Nearby.fromJson(dynamic json) {
    hnId = json['hn_id'];
    hnPlace = json['hn_place'];
    hnLat = json['hn_lat'];
    hnLong = json['hn_long'];
    hnDistance = json['hn_distance'];
    hId = json['h_id'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hn_id'] = hnId;
    map['hn_place'] = hnPlace;
    map['hn_lat'] = hnLat;
    map['hn_long'] = hnLong;
    map['hn_distance'] = hnDistance;
    map['h_id'] = hId;
    return map;
  }

}