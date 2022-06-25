class Meal {
  String? hmId;
  String? hId;
  String? hmBreakfast;
  String? hmB;
  String? hmLunch;
  String? hmL;
  String? hmDinner;
  String? hmD;
  String? isDelete;

  Meal({
      String? hmId, 
      String? hId, 
      String? hmBreakfast, 
      String? hmB, 
      String? hmLunch, 
      String? hmL, 
      String? hmDinner, 
      String? hmD, 
      String? isDelete
  });

  Meal.fromJson(dynamic json) {
    hmId = json['hm_id'];
    hId = json['h_id'];
    hmBreakfast = json['hm_breakfast'];
    hmB = json['hm_b'];
    hmLunch = json['hm_lunch'];
    hmL = json['hm_l'];
    hmDinner = json['hm_dinner'];
    hmD = json['hm_d'];
    isDelete = json['is_delete'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hm_id'] = hmId;
    map['h_id'] = hId;
    map['hm_breakfast'] = hmBreakfast;
    map['hm_b'] = hmB;
    map['hm_lunch'] = hmLunch;
    map['hm_l'] = hmL;
    map['hm_dinner'] = hmDinner;
    map['hm_d'] = hmD;
    map['is_delete'] = isDelete;
    return map;
  }

}