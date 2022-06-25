/// br_id : "1"
/// br_location : "Reviews/1647415255.jpg"
/// br_facilities : null

class Reviews {
  String? brId;
  String? brLocation;
  String? brFood;
  String? brCleanliness;
  String? brStaff;
  String? brFacilities;
  String? brReview;
  String? brDate;
  String? cusName;

  Reviews({
      String? brId, 
      String? brLocation, 
      String? brFood,
      String? brCleanliness,
      String? brStaff,
      String? brFacilities,
      String? brReview,
      String? brDate,
      String? cusName
  });

  Reviews.fromJson(dynamic json) {
    brId = json['br_id'];
    brLocation = json['br_location'];
    brFood = json['br_food'];
    brCleanliness = json['br_cleanliness'];
    brStaff = json['br_staff'];
    brFacilities = json['br_facilities'];
    brReview = json['br_review'];
    brDate = json['br_date'];
    cusName = json['cus_name'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['br_id'] = brId;
    map['br_location'] = brLocation;
    map['br_food'] = brFood;
    map['br_cleanliness'] = brCleanliness;
    map['br_staff'] = brStaff;
    map['br_facilities'] = brFacilities;
    map['br_review'] = brReview;
    map['br_date'] = brDate;
    map['cus_name'] = cusName;
    return map;
  }

}