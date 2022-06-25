class Bookings {
  String? bId;
  String? bNo;
  String? bName;
  String? bMobile;
  String? bDate;
  String? bRequest;
  String? brTimePeriod;
  String? brStart;
  String? brEnd;
  String? hId;
  String? hName;
  String? hAddress;
  String? hgLat;
  String? hgLong;
  String? hgHelplineCustomer;
  String? catName;
  String? billAmount;
  String? billTotal;
  String? billDiscountAmount;
  String? billPay;
  String? bDeposit;
  String? due;
  String? totalRooms;
  String? brAdult;
  String? brChild;
  String? brGuest;
  String? bBreakfast;
  String? bLunch;
  String? bDinner;
  String? bBprice;
  String? bLprice;
  String? bDprice;
  String? bStatus;
  String? bcDate;
  String? crName;
  String? bcDescription;
  String? bcRefund;
  String? refundStatus;
  String? brLocation;
  String? brFood;
  String? brCleanliness;
  String? brStaff;
  String? brFacilities;
  String? brReview;
  String? brDate;

  Bookings({
    String? bId,
    String? bNo,
    String? bName,
    String? bMobile,
    String? bDate,
    String? bRequest,
    String? brTimePeriod,
    String? brStart,
    String? brEnd,
    String? hId,
    String? hName,
    String? hAddress,
    String? hgLat,
    String? hgLong,
    String? hgHelplineCustomer,
    String? catName,
    String? billAmount,
    String? billTotal,
    String? billDiscountAmount,
    String? billPay,
    String? bDeposit,
    String? due,
    String? totalRooms,
    String? brAdult,
    String? brChild,
    String? brGuest,
    String? bBreakfast,
    String? bLunch,
    String? bDinner,
    String? bBprice,
    String? bLprice,
    String? bDprice,
    String? bStatus,
    String? bcDate,
    String? crName,
    String? bcDescription,
    String? bcRefund,
    String? refundStatus,
    String? brLocation,
    String? brFood,
    String? brCleanliness,
    String? brStaff,
    String? brFacilities,
    String? brReview,
    String? brDate,
  });

  Bookings.fromJson(dynamic json) {
    bId = json['b_id'];
    bNo = json['b_no'];
    bName = json['b_name'];
    bMobile = json['b_mobile'];
    hId = json['h_id'];
    bDate = json['b_date'];
    bRequest = json['b_request'];
    brTimePeriod = json['br_time_period'];
    brStart = json['br_start'];
    brEnd = json['br_end'];
    hName = json['h_name'];
    hAddress = json['h_address'];
    hgLat = json['hg_lat'];
    hgLong = json['hg_long'];
    hgHelplineCustomer = json['hg_helpline_customer'];
    catName = json['cat_name'];
    billAmount = json['bill_amount'];
    billTotal = json['bill_total'];
    billDiscountAmount = json['bill_discount_amount'];
    billPay = json['bill_pay'];
    bDeposit = json['b_deposit'];
    due = json['due'];
    totalRooms = json['total_rooms'];
    brAdult = json['br_adult'];
    brChild = json['br_child'];
    brGuest = json['br_guest'];
    bBreakfast = json['b_breakfast'];
    bLunch = json['b_lunch'];
    bDinner = json['b_dinner'];
    bBprice = json['b_bprice'];
    bLprice = json['b_lprice'];
    bDprice = json['b_dprice'];
    bStatus = json['b_status'];
    bcDate = json['bc_date'];
    crName = json['cr_name'];
    bcDescription = json['bc_description'];
    bcRefund = json['bc_refund'];
    refundStatus = json['refund_status'];
    brLocation = json['br_location'];
    brFood = json['br_food'];
    brCleanliness = json['br_cleanliness'];
    brStaff = json['br_staff'];
    brFacilities = json['br_facilities'];
    brReview = json['br_review'];
    brDate = json['br_date'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['b_id'] = bId;
    map['b_no'] = bNo;
    map['b_name'] = bName;
    map['b_mobile'] = bMobile;
    map['h_id'] = hId;
    map['b_date'] = bDate;
    map['b_request'] = bRequest;
    map['br_time_period'] = brTimePeriod;
    map['br_start'] = brStart;
    map['br_end'] = brEnd;
    map['h_name'] = hName;
    map['h_address'] = hAddress;
    map['hg_lat'] = hgLat;
    map['hg_long'] = hgLong;
    map['hg_helpline_customer'] = hgHelplineCustomer;
    map['cat_name'] = catName;
    map['bill_amount'] = billAmount;
    map['bill_total'] = billTotal;
    map['bill_discount_amount'] = billDiscountAmount;
    map['bill_pay'] = billPay;
    map['b_deposit'] = bDeposit;
    map['due'] = due;
    map['total_rooms'] = totalRooms;
    map['br_adult'] = brAdult;
    map['br_child'] = brChild;
    map['br_guest'] = brGuest;
    map['b_breakfast'] = bBreakfast;
    map['b_lunch'] = bLunch;
    map['b_dinner'] = bDinner;
    map['b_bprice'] = bBprice;
    map['b_lprice'] = bLprice;
    map['b_dprice'] = bDprice;
    map['b_status'] = bStatus;
    map['bc_date'] = bcDate;
    map['cr_name'] = crName;
    map['bc_description'] = bcDescription;
    map['bc_refund'] = bcRefund;
    map['refund_status'] = refundStatus;
    map['br_location'] = brLocation;
    map['br_food'] = brFood;
    map['br_cleanliness'] = brCleanliness;
    map['br_staff'] = brStaff;
    map['br_facilities'] = brFacilities;
    map['br_review'] = brReview;
    map['br_date'] = brDate;
    return map;
  }

}