import 'package:olr_rooms_web/model/Response.dart';

/// b_id : "1"
/// api_key : "ConfirmBookingResponse/1647415255.jpg"
/// h_id : null

class ConfirmBookingResponse extends Response{
  String? bId;
  String? apiKey;
  String? billNo;

  ConfirmBookingResponse({
      String? bId, 
      String? apiKey,
      String? billNo
  });

  ConfirmBookingResponse.fromJson(dynamic json) : super.fromJson(json) {
    bId = json['b_id'];
    apiKey = json['api_key'];
    billNo = json['bill_no'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map.addAll(super.toJson());
    map['b_id'] = bId;
    map['api_key'] = apiKey;
    map['bill_no'] = billNo;
    return map;
  }

}