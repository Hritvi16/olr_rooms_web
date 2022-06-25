/// cus_id : "3"
/// cus_name : "Hritvi"
/// cus_email : "hritvi16gajiwala@gmail.com"
/// cus_cc : "+91"
/// cus_mobile : "9586033791"
/// cus_gender : null
/// c_id : "2"
/// cus_dob : "0000-00-00"
/// cus_gst : null
/// cus_gst_legal_name : null
/// cus_gst_address : null
/// cus_type : "OLR"
/// created_at : "2022-03-17 05:27:42"
/// is_delete : "0"

class UserDetails {
  String? cusId;
  String? cusName;
  String? cusEmail;
  String? cusCc;
  String? cusMobile;
  String? cusGender;
  String? cId;
  String? cusDob;
  String? cusGst;
  String? cusGstLegalName;
  String? cusGstAddress;
  String? cusStateCode;
  String? cusType;
  String? createdAt;
  String? isDelete;
  
  UserDetails({
      String? cusId,
      String? cusName, 
      String? cusEmail, 
      String? cusCc, 
      String? cusMobile, 
      String? cusGender, 
      String? cId, 
      String? cusDob, 
      String? cusGst, 
      String? cusGstLegalName, 
      String? cusGstAddress, 
      String? cusStateCode,
      String? cusType,
      String? createdAt, 
      String? isDelete,});

  UserDetails.fromJson(Map<String, dynamic>? json) {
    if(json!=null) {
      cusId = json['cus_id'];
      cusName = json['cus_name'];
      cusEmail = json['cus_email'];
      cusCc = json['cus_cc'];
      cusMobile = json['cus_mobile'];
      cusGender = json['cus_gender'];
      cId = json['c_id'];
      cusDob = json['cus_dob'];
      cusGst = json['cus_gst'];
      cusGstLegalName = json['cus_gst_legal_name'];
      cusGstAddress = json['cus_gst_address'];
      cusStateCode = json['cus_state_code'];
      cusType = json['cus_type'];
      createdAt = json['created_at'];
      isDelete = json['is_delete'];
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['cus_id'] = cusId;
    map['cus_name'] = cusName;
    map['cus_email'] = cusEmail;
    map['cus_cc'] = cusCc;
    map['cus_mobile'] = cusMobile;
    map['cus_gender'] = cusGender;
    map['c_id'] = cId;
    map['cus_dob'] = cusDob;
    map['cus_gst'] = cusGst;
    map['cus_gst_legal_name'] = cusGstLegalName;
    map['cus_gst_address'] = cusGstAddress;
    map['cus_state_code'] = cusStateCode;
    map['cus_type'] = cusType;
    map['created_at'] = createdAt;
    map['is_delete'] = isDelete;
    return map;
  }

}