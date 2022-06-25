class Offers {
  Offers({
      String? id, 
      String? name, 
      String? code, 
      String? discount, 
      String? discountType, 
      String? short,
      String? description,
      String? image,
      String? startDate,
      String? endDate,
  });

  Offers.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    discount = json['discount'];
    discountType = json['discount_type'];
    short = json['short'];
    description = json['description'];
    image = json['image'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }
  String? id;
  String? name;
  String? code;
  String? discount;
  String? discountType;
  String? short;
  String? description;
  String? image;
  String? startDate;
  String? endDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['code'] = code;
    map['discount'] = discount;
    map['discount_type'] = discountType;
    map['short'] = short;
    map['description'] = description;
    map['image'] = image;
    map['start_date'] = startDate;
    map['end_date'] = endDate;
    return map;
  }

}