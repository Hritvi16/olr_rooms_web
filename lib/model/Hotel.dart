class Hotel {
  String? hId;
  String? hName;
  String? hAddress;
  String? hPincode;
  String? hLandmark;
  String? coId;
  String? sId;
  String? cId;
  String? arId;
  String? hStar;
  String? hImageCount;
  String? hRating;
  String? hTotalRating;
  String? isDelete;
  String? hgHelplineCustomer;
  String? hgLat;
  String? hgLong;
  String? hgDeposit;
  String? hgDepositType;
  String? hgPayAtHotel;
  String? hgPolicy;
  String? hgShortDesc;
  String? hgLongDesc;
  String? catId;
  String? catName;
  String? catDesc;
  String? catAdult;
  String? catChild;
  String? catPeople;
  String? cpBase;
  String? cpDiscount;
  String? liked;

  Hotel({
      String? hId, 
      String? hName, 
      String? hAddress, 
      String? hPincode, 
      String? hLandmark, 
      String? coId, 
      String? sId, 
      String? cId, 
      String? arId, 
      String? hStar, 
      String? hImageCount, 
      String? hRating,
      String? hTotalRating,
      String? isDelete,
      String? hgHelplineCustomer,
      String? hgLat,
      String? hgLong,
      String? hgDeposit,
      String? hgDepositType,
      String? hgPayAtHotel,
      String? hgPolicy,
      String? hgShortDesc,
      String? hgLongDesc,
      String? catId,
      String? catName,
      String? catDesc,
      String? catAdult,
      String? catChild,
      String? catPeople,
      String? cpBase,
      String? cpDiscount,
      String? liked
  });

  Hotel.fromJson(dynamic json) {
    hId = json['h_id'];
    hName = json['h_name'];
    hAddress = json['h_address'];
    hPincode = json['h_pincode'];
    hLandmark = json['h_landmark'];
    coId = json['co_id'];
    sId = json['s_id'];
    cId = json['c_id'];
    arId = json['ar_id'];
    hStar = json['h_star'];
    hImageCount = json['h_image_count'];
    hRating = json['h_rating'];
    hTotalRating = json['h_total_rating'];
    isDelete = json['is_delete'];
    hgHelplineCustomer = json['hg_helpline_customer'];
    hgLat = json['hg_lat'];
    hgLong = json['hg_long'];
    hgDeposit = json['hg_deposit'];
    hgDepositType = json['hg_deposit_type'];
    hgPayAtHotel = json['hg_pay_at_hotel'];
    hgShortDesc = json['hg_short_desc'];
    hgLongDesc = json['hg_long_desc'];
    hgPolicy = json['hg_policy'];
    catId = json['cat_id'];
    catName = json['cat_name'];
    catDesc = json['cat_desc'];
    catAdult = json['cat_adult'];
    catChild = json['cat_child'];
    catPeople = json['cat_people'];
    cpBase = json['cp_base'];
    cpDiscount = json['cp_discount'];
    liked = json['liked'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['h_id'] = hId;
    map['h_name'] = hName;
    map['h_address'] = hAddress;
    map['h_pincode'] = hPincode;
    map['h_landmark'] = hLandmark;
    map['co_id'] = coId;
    map['s_id'] = sId;
    map['c_id'] = cId;
    map['ar_id'] = arId;
    map['h_star'] = hStar;
    map['h_image_count'] = hImageCount;
    map['h_rating'] = hRating;
    map['h_total_rating'] = hTotalRating;
    map['is_delete'] = isDelete;
    map['hg_helpline_customer'] = hgHelplineCustomer;
    map['hg_lat'] = hgLat;
    map['hg_long'] = hgLong;
    map['hg_deposit'] = hgDeposit;
    map['hg_deposit_type'] = hgDepositType;
    map['hg_pay_at_hotel'] = hgPayAtHotel;
    map['hg_policy'] = hgPolicy;
    map['hg_short_desc'] = hgShortDesc;
    map['hg_long_desc'] = hgLongDesc;
    map['cat_id'] = catId;
    map['cat_name'] = catName;
    map['cat_desc'] = catDesc;
    map['cat_adult'] = catAdult;
    map['cat_child'] = catChild;
    map['cat_people'] = catPeople;
    map['cp_base'] = cpBase;
    map['cp_discount'] = cpDiscount;
    map['liked'] = liked;
    return map;
  }

}