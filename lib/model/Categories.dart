class Categories {
  Categories({
      String? catId, 
      String? catName, 
      String? catDesc, 
      String? catAdult, 
      String? catChild, 
      String? catPeople, 
      String? cpId, 
      String? catSlot, 
      String? cpBase, 
      String? cpDiscount,});

  Categories.fromJson(dynamic json) {
    catId = json['cat_id'];
    catName = json['cat_name'];
    catDesc = json['cat_desc'];
    catAdult = json['cat_adult'];
    catChild = json['cat_child'];
    catPeople = json['cat_people'];
    cpId = json['cp_id'];
    catSlot = json['cat_slot'];
    cpBase = json['cp_base'];
    cpDiscount = json['cp_discount'];
  }
  String? catId;
  String? catName;
  String? catDesc;
  String? catAdult;
  String? catChild;
  String? catPeople;
  String? cpId;
  String? catSlot;
  String? cpBase;
  String? cpDiscount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['cat_desc'] = catDesc;
    map['cat_adult'] = catAdult;
    map['cat_child'] = catChild;
    map['cat_people'] = catPeople;
    map['cp_id'] = cpId;
    map['cat_slot'] = catSlot;
    map['cp_base'] = cpBase;
    map['cp_discount'] = cpDiscount;
    return map;
  }

}